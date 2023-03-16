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

import Foundation
import SwiftUI
import JudoModel

struct TextView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties
    @Environment(\.isBold) private var isBold
    @Environment(\.isItalic) private var isItalic

    @ObservedObject private var text: JudoModel.Text

    init(text: JudoModel.Text) {
        self.text = text
    }

    var body: some SwiftUI.View {
        RealizeText(text.value.description) { textString in
            if let textValue = try? textString.evaluatingExpressions(data: data, properties: properties) {
                SwiftUI.Text(textValue)
                    .backport.bold(isBold)
                    .backport.italic(isItalic)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct RealizeText<Content>: SwiftUI.View where Content: SwiftUI.View {
    @EnvironmentObject private var localizations: DocumentLocalizations

    private var text: String
    private var content: (String) -> Content

    init(_ text: String, @ViewBuilder content: @escaping (String) -> Content) {
        self.text = text
        self.content = content
    }

    @ViewBuilder
    var body: some SwiftUI.View {
        content(textForDisplay)
    }

    var textForDisplay: String {
        let preferredLocale = Locale.preferredLocale()

        if let matchedLocale = localizations[preferredLocale.identifier], let translation = matchedLocale[text] {
            return translation
        }

        if  let languageCode = preferredLocale.languageCode,
            let matchedLocale = localizations.fuzzyMatch(key: languageCode),
            let translation = matchedLocale[text] {
            return translation
        }

        return text
    }
}

private extension Locale {
    static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }

        switch preferredIdentifier.lowercased(with: Locale(identifier: "en-US")) {
        case "zh-hant":
            return Locale(identifier: "zh-CN")
        case "zh-hans":
            return Locale(identifier: "zh-TW")
        default:
            return Locale(identifier: preferredIdentifier)
        }
    }
}
