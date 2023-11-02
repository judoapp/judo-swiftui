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

struct FontViewModifier: SwiftUI.ViewModifier {
    @Environment(\.document) private var document

    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    @Environment(\.sizeCategory) private var sizeCategory

    var modifier: JudoDocument.FontModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .font(uiFont)
    }

    private var uiFont: SwiftUI.Font {
        switch modifier.font {
        case .dynamic(let textStyle, let design):
            return SwiftUI.Font.system(textStyle.swiftUIValue, design: design.swiftUIValue)
        case .fixed(let size, let weight, let design):
            return SwiftUI.Font.system(
                size: size.forceResolve(
                    properties: componentState.properties,
                    data: data
                ),
                weight: weight.swiftUIValue,
                design: design.swiftUIValue
            )
        case .document(let fontFamily, let textStyle):
            guard let fontMetrics = document.fonts.first(where: { $0.fontFamily == fontFamily }) else {
                assertionFailure("No font metrics found with family name: \(fontFamily)")
                return SwiftUI.Font.system(.body)
            }

            return getFont(
                with: fontMetrics[textStyle].fontName,
                size: fontMetrics[textStyle].size * accessibilitySizeAdjustmentRatio
            )
        case .custom(let fontName, let size):
            return getFont(
                with: fontName,
                size: size.forceResolve(
                    properties: componentState.properties,
                    data: data
                )
            )
        }
    }

    // Get the font by name and size by first searching the bundled fonts,
    // if the font is not bundled (this is considered an invalid state) default to asking the system
    // to provide the font. In the case where the user does not have the font installed on their system
    // SwiftUI will default to system font.
    private func getFont(with fontName: String, size: CGFloat) -> SwiftUI.Font {
        let fallback = SwiftUI.Font.custom(fontName, size: size)
        
        guard let fontValue = document.importedFonts.first(where: { $0.fontNames.contains(fontName) }) else {
            return fallback
        }

        guard let fontDescriptor = CTFontManagerCreateFontDescriptorFromData(fontValue.data as CFData) else {
            return fallback
        }
        
        let ctFont = CTFontCreateWithFontDescriptor(fontDescriptor, size, nil)
        return SwiftUI.Font(ctFont)
    }

    private var accessibilitySizeAdjustmentRatio: CGFloat {
        let textStyle = FontTextStyle.body
        return textStyle.size(forCategory: sizeCategory) / textStyle.size(forCategory: .large)
    }
}

private extension FontTextStyle {
    var swiftUIValue: SwiftUI.Font.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .title2:
            if #available(iOS 14.0, *) {
                return .title2
            } else {
                return .title
            }
        case .title3:
            if #available(iOS 14.0, *) {
                return .title3
            } else {
                return .title
            }
        case .headline:
            return .headline
        case .body:
            return .body
        case .callout:
            return .callout
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        case .caption2:
            if #available(iOS 14.0, *) {
                return .caption2
            } else {
                return .caption
            }
        }
    }
    
    func size(forCategory sizeCategory: SwiftUI.ContentSizeCategory) -> CGFloat {
        // https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
        let sizeTable: [SwiftUI.ContentSizeCategory: [FontTextStyle: CGFloat]] = [
            .extraSmall: [
                .largeTitle: 31,
                .title: 25,
                .title2: 19,
                .title3: 17,
                .headline: 14,
                .body: 14,
                .callout: 13,
                .subheadline: 12,
                .footnote: 12,
                .caption: 11,
                .caption2: 11
            ],
            .small: [
                .largeTitle: 32,
                .title: 26,
                .title2: 20,
                .title3: 18,
                .headline: 15,
                .body: 15,
                .callout: 14,
                .subheadline: 13,
                .footnote: 12,
                .caption: 11,
                .caption2: 11
            ],
            .medium: [
                .largeTitle: 33,
                .title: 27,
                .title2: 21,
                .title3: 19,
                .headline: 16,
                .body: 16,
                .callout: 15,
                .subheadline: 14,
                .footnote: 12,
                .caption: 11,
                .caption2: 11
            ],
            .large: [
                .largeTitle: 34,
                .title: 28,
                .title2: 22,
                .title3: 20,
                .headline: 17,
                .body: 17,
                .callout: 16,
                .subheadline: 15,
                .footnote: 13,
                .caption: 12,
                .caption2: 11
            ],
            .extraLarge: [
                .largeTitle: 36,
                .title: 30,
                .title2: 24,
                .title3: 22,
                .headline: 19,
                .body: 19,
                .callout: 18,
                .subheadline: 17,
                .footnote: 15,
                .caption: 14,
                .caption2: 13
            ],
            .extraExtraLarge: [
                .largeTitle: 38,
                .title: 32,
                .title2: 26,
                .title3: 24,
                .headline: 21,
                .body: 21,
                .callout: 20,
                .subheadline: 19,
                .footnote: 17,
                .caption: 16,
                .caption2: 15
            ],
            .extraExtraExtraLarge: [
                .largeTitle: 40,
                .title: 34,
                .title2: 28,
                .title3: 26,
                .headline: 23,
                .body: 23,
                .callout: 22,
                .subheadline: 21,
                .footnote: 19,
                .caption: 18,
                .caption2: 17
            ],
            .accessibilityMedium: [
                .largeTitle: 44,
                .title: 38,
                .title2: 34,
                .title3: 31,
                .headline: 28,
                .body: 28,
                .callout: 26,
                .subheadline: 25,
                .footnote: 23,
                .caption: 22,
                .caption2: 20
            ],
            .accessibilityLarge: [
                .largeTitle: 48,
                .title: 43,
                .title2: 39,
                .title3: 37,
                .headline: 33,
                .body: 33,
                .callout: 32,
                .subheadline: 30,
                .footnote: 27,
                .caption: 26,
                .caption2: 24
            ],
            .accessibilityExtraLarge: [
                .largeTitle: 52,
                .title: 48,
                .title2: 44,
                .title3: 43,
                .headline: 40,
                .body: 40,
                .callout: 38,
                .subheadline: 36,
                .footnote: 33,
                .caption: 32,
                .caption2: 29
            ],
            .accessibilityExtraExtraLarge: [
                .largeTitle: 56,
                .title: 53,
                .title2: 50,
                .title3: 49,
                .headline: 47,
                .body: 47,
                .callout: 44,
                .subheadline: 42,
                .footnote: 38,
                .caption: 37,
                .caption2: 34
            ],
            .accessibilityExtraExtraExtraLarge: [
                .largeTitle: 60,
                .title: 58,
                .title2: 56,
                .title3: 55,
                .headline: 53,
                .body: 53,
                .callout: 51,
                .subheadline: 49,
                .footnote: 44,
                .caption: 43,
                .caption2: 40
            ]
        ]

        return sizeTable[sizeCategory]?[self] ?? 0
    }
}

private extension FontWeight {
    var swiftUIValue: SwiftUI.Font.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }
}

private extension FontDesign {
    var swiftUIValue: SwiftUI.Font.Design {
        switch self {
        case .default:
            return .default
        case .monospaced:
            return .monospaced
        case .rounded:
            return .rounded
        case .serif:
            return .serif
        }
    }
}
