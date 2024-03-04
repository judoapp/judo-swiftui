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

import JudoDocument
import SwiftUI

struct RealizeText<Content>: SwiftUI.View where Content: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data
    @Environment(\.document) private var document

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
            realizeText(value, localized: localized, strings: document.strings, propertyValues: componentState.propertyValues, data: data)
        )
    }
}

func realizeText(_ text: Variable<String>, localized: Bool, strings: StringsCatalog, propertyValues: [String: PropertyValue], data: Any?) -> String {
    let resolvedValue = text.forceResolve(propertyValues: propertyValues, data: data)
    let evaluatedValue = (try? resolvedValue.evaluatingExpressions(data: data, propertyValues: propertyValues)) ?? resolvedValue

    if localized {
        return localize(key: evaluatedValue, locale: Locale.preferredLocale, strings: strings) ?? evaluatedValue
    } else {
        return evaluatedValue
    }
}

func localize(key: String?, locale: Locale?, strings: StringsCatalog) -> String? {

    // A simple (and not complete) attempt at RFC 4647 basic filtering.
    guard let localeIdentifier = locale?.identifier else {
        return key
    }

    guard let key else {
        return key
    }

    if let matchedLocale = strings[localeIdentifier], let translation = matchedLocale[key] {
        return translation
    }

    if #available(iOS 16, *) {
        if  let languageCode = Locale(identifier: localeIdentifier).language.languageCode?.identifier,
            let matchedLocale = strings.table(for: languageCode),
            let translation = matchedLocale[key] {
            return translation
        }
    } else {
        if  let languageCode = Locale(identifier: localeIdentifier).languageCode,
            let matchedLocale = strings.table(for: languageCode),
            let translation = matchedLocale[key] {
            return translation
        }
    }

    return key
}
