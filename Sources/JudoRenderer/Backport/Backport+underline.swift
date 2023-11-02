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

import Backport
import JudoDocument
import SwiftUI

extension Backport where Wrapped: SwiftUI.View {

    /// In iOS 16+ the .underline() modifier can be applied to any SwiftUI View. Prior to iOS 16 it can only be applied to a SwiftUI.Text view.
    ///
    /// To get around this the UnderlineViewModifier checks the current OS version and applies different behaviours:
    /// - If we're running iOS 16, it applies the .underline() modifier to the content as normal.
    /// - Prior to 16, it simply sets an environment value that will be handled by the TextView.
    @ViewBuilder
    func underline(_ isActive: Bool = true, pattern: TextLineStylePattern , color: Color?) -> some SwiftUI.View {
        if #available(iOS 16, macOS 13, *) {
            wrapped
                .underline(isActive, pattern: Backport.getPattern(from: pattern), color: color)
        } else {
            wrapped
                .environment(\.isUnderlined, (isActive, color))
        }
    }

    @available(iOS 15.0, *)
    private static func getPattern(from pattern: TextLineStylePattern) -> SwiftUI.Text.LineStyle.Pattern {
        switch pattern {
        case .solid:
            return .solid
        case .dot:
            return .dot
        case .dash:
            return .dash
        case .dashDot:
            return .dashDot
        case .dashDotDot:
            return .dashDotDot
        }
    }
}
