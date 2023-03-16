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

struct FontViewModifier: SwiftUI.ViewModifier {
    @EnvironmentObject private var fontStore: ImportedFonts
    @EnvironmentObject private var documentState: DocumentData
    @Environment(\.sizeCategory) private var sizeCategory

    @ObservedObject var modifier: JudoModel.FontModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .font(uiFont)
    }

    private var uiFont: SwiftUI.Font {
        switch modifier.font {
        case .dynamic(let textStyle, let design):
            return SwiftUI.Font.system(textStyle.swiftUIValue, design: design.swiftUIValue)
        case .fixed(let size, let weight, let design):
            return SwiftUI.Font.system(size: size, weight: weight.swiftUIValue, design: design.swiftUIValue)
        case .document(let fontFamily, let textStyle):
            guard let documentFont = documentState.fonts.first(where: { $0.fontFamily == fontFamily }) else {
                assertionFailure("No document found with family name: \(fontFamily)")
                return SwiftUI.Font.system(.body)
            }

            return getFont(
                with: documentFont[textStyle].fontName,
                size: documentFont[textStyle].size * accessibilitySizeAdjustmentRatio
            )
        case .custom(let fontName, let size):
            return getFont(with: fontName, size: size)
        }
    }

    // Get the font by name and size by first searching the bundled fonts,
    // if the font is not bundled (this is considered an invalid state) default to asking the system
    // to provide the font. In the case where the user does not have the font installed on their system
    // SwiftUI will default to system font.
    private func getFont(with fontName: String, size: CGFloat) -> SwiftUI.Font {
        if let font = fontStore.getFont(from: fontName, fontSize: size) {
            return SwiftUI.Font(font)
        } else {
            return SwiftUI.Font.custom(fontName, size: size)
        }
    }

    private var accessibilitySizeAdjustmentRatio: CGFloat {
        let textStyle = FontTextStyle.body
        return textStyle.size(forCategory: sizeCategory) / textStyle.size(forCategory: .large)
    }
}
