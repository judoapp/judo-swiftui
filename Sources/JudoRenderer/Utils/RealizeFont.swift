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

func realizeFont(_ font: JudoDocument.Font, documentNode: DocumentNode, sizeCategory: SwiftUI.ContentSizeCategory, propertyValues: [String: PropertyValue], data: Any?) -> SwiftUI.Font {

    // Get the font by name and size by first searching the bundled fonts,
    // if the font is not bundled (this is considered an invalid state) default to asking the system
    // to provide the font. In the case where the user does not have the font installed on their system
    // SwiftUI will default to system font.
    func getFont(with fontName: String, size: CGFloat) -> SwiftUI.Font {
        let fallback = SwiftUI.Font.custom(fontName, size: size)

        guard let fontValue = documentNode.importedFonts.first(where: { $0.fontNames.contains(fontName) }) else {
            return fallback
        }

        guard let fontDescriptor = CTFontManagerCreateFontDescriptorFromData(fontValue.data as CFData) else {
            return fallback
        }

        let ctFont = CTFontCreateWithFontDescriptor(fontDescriptor, size, nil)
        return SwiftUI.Font(ctFont)
    }

    switch font {
    case .dynamic(let textStyle, let design):
        return SwiftUI.Font.system(textStyle.swiftUIValue, design: design.swiftUIValue)
    case .fixed(let size, let weight, let design):
        return SwiftUI.Font.system(
            size: size.forceResolve(
                propertyValues: propertyValues,
                data: data
            ),
            weight: weight.swiftUIValue ?? .regular,
            design: design.swiftUIValue
        )
    case .document(let fontFamily, let textStyle):
        guard let fontMetrics = documentNode.fonts.first(where: { $0.fontFamily == fontFamily }) else {
            assertionFailure("No font metrics found with family name: \(fontFamily)")
            return SwiftUI.Font.system(.body)
        }

        var accessibilitySizeAdjustmentRatio: CGFloat {
            let textStyle = FontTextStyle.body
            return textStyle.size(forCategory: sizeCategory) / textStyle.size(forCategory: .large)
        }

        return getFont(
            with: fontMetrics[textStyle].fontName,
            size: fontMetrics[textStyle].size * accessibilitySizeAdjustmentRatio
        )
    case .custom(let fontName, let size):
        return getFont(
            with: fontName,
            size: size.forceResolve(
                propertyValues: propertyValues,
                data: data
            )
        )
    }
}

