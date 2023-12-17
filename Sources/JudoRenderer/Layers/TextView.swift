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
import JudoDocument

struct TextView: SwiftUI.View {
    @Environment(\.isBold) private var isBold
    @Environment(\.isItalic) private var isItalic
    @Environment(\.isUnderlined) private var isUnderlined
    @Environment(\.fontWeight) private var fontWeight
    @Environment(\.kerning) private var kerning
    @Environment(\.tracking) private var tracking

    private var text: JudoDocument.TextNode

    init(text: JudoDocument.TextNode) {
        self.text = text
    }

    var body: some SwiftUI.View {
        RealizeText(text.value) { text in
            textContent(text)
        }
    }
    
    @ViewBuilder
    private func textContent(_ string: String) -> some View {
        /// Apply the modifiers if running less than iOS 16
        if #available(iOS 16, macOS 13, *) {
            SwiftUI.Text(string)
        } else {
            SwiftUI.Text(string)
                .conditionalBold(isBold)
                .conditionalItalic(isItalic)
                .conditionalUnderline(isUnderlined)
                .conditionalFontWeight(fontWeight)
                .conditionalKerning(kerning)
                .conditionalTracking(tracking)
        }
    }
}

private extension SwiftUI.Text {
    func conditionalBold(_ condition: Bool) -> Self {
        if condition {
            self.bold()
        } else {
            self
        }
    }

    func conditionalItalic(_ condition: Bool) -> Self {
        if condition {
            self.italic()
        } else {
            self
        }
    }

    func conditionalUnderline(_ value: (isActive: Bool, color: Color?)) -> Self {
        if value.isActive {
            self.underline(value.isActive, color: value.color)
        } else {
            self
        }
    }

    func conditionalFontWeight(_ fontWeight: FontWeight?) -> Self {
        if fontWeight != FontWeight.none {
            self.fontWeight(fontWeight?.swiftUIValue)
        } else {
            self
        }
    }

    func conditionalKerning(_ kerning: CGFloat) -> Self {
        self.kerning(kerning)
    }

    func conditionalTracking(_ tracking: CGFloat) -> Self {
        self.tracking(tracking)
    }
}

private extension FontWeight {
    var swiftUIValue: SwiftUI.Font.Weight? {
        switch self {
        case .none:
            return nil
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
