// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import JudoModel
import SwiftUI

struct RealizeText<Content>: SwiftUI.View where Content: SwiftUI.View {
    @EnvironmentObject private var localizations: DocumentLocalizations
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    private let value: Variable<String>
    private let content: (String) -> Content
    private let localized: Bool

    init(_ text: Variable<String>, localized: Bool = true, @ViewBuilder content: @escaping (String) -> Content) {
        self.value = text
        self.content = content
        self.localized = localized
    }

    var body: some View {
        content(
            localized ? localizedValue : evaluatedValue
        )
    }

    private var localizedValue: String {
        localize(
            key: evaluatedValue,
            locale: Locale.preferredLocale,
            localizations: localizations
        ) ?? evaluatedValue
    }

    private var evaluatedValue: String {
        (try? resolvedValue.evaluatingExpressions(data: data, properties: componentState.properties)) ?? resolvedValue
    }

    private var resolvedValue: String {
        value.forceResolve(
            properties: componentState.properties,
            data: data
        )
    }
}

func localize(key: String?, locale: Locale?, localizations: DocumentLocalizations) -> String? {

    // A simple (and not complete) attempt at RFC 4647 basic filtering.
    guard let localeIdentifier = locale?.identifier else {
        return key
    }

    guard let key else {
        return key
    }

    if let matchedLocale = localizations[localeIdentifier], let translation = matchedLocale[key] {
        return translation
    }

    if #available(iOS 16, *) {
        if  let languageCode = Locale(identifier: localeIdentifier).language.languageCode?.identifier,
            let matchedLocale = localizations.fuzzyMatch(key: languageCode),
            let translation = matchedLocale[key] {
            return translation
        }
    } else {
        if  let languageCode = Locale(identifier: localeIdentifier).languageCode,
            let matchedLocale = localizations.fuzzyMatch(key: languageCode),
            let translation = matchedLocale[key] {
            return translation
        }
    }

    return key
}
