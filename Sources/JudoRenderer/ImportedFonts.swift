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
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import JudoModel

/// Stores the user added fonts in memory
final class ImportedFonts: ObservableObject {
    var fonts: Set<FontValue> = []

    func removeFonts(with fontNames: Set<FontName>) -> Set<FontValue> {
        fonts.filter {
            Set($0.fontNames).intersection(fontNames).isEmpty
        }
    }

    /// Retrieves the CTFont from the imported fonts given the font name and font size
    /// This will only return a CTFont if it has been imported
    func getFont(from fontName: FontName, fontSize size: CGFloat) -> CTFont? {
        guard let fontValue = fonts.first(where: { $0.fontNames.contains(fontName) }) else {
            return nil
        }

        guard let fontDescriptor = CTFontManagerCreateFontDescriptorFromData(fontValue.data as CFData) else { return nil }
        return CTFontCreateWithFontDescriptor(fontDescriptor, size, nil)
    }

    func has(fontNames: Set<FontName>) -> Bool {
        fontNames.allSatisfy { fontName in
            fonts.contains { $0.fontNames.contains(fontName) }
        }
    }
}
