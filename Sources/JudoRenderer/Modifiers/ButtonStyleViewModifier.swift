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

struct ButtonStyleViewModifier: SwiftUI.ViewModifier {
    var modifier: ButtonStyleModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .modifier(SwiftUIButtonStyleModifier(buttonStyle: modifier.buttonStyle))
    }
}

private struct SwiftUIButtonStyleModifier: SwiftUI.ViewModifier {
    let buttonStyle: JudoDocument.ButtonStyle

    func body(content: Content) -> some SwiftUI.View {
        switch buttonStyle {
        case .automatic:
            content.buttonStyle(.automatic)
        case .plain:
            content.buttonStyle(.plain)
        case .borderless:
            content.buttonStyle(.borderless)
        case .bordered:
            if #available(iOS 15.0, *) {
                content.buttonStyle(.bordered)
            } else {
                content.buttonStyle(.automatic)
            }
        case .borderedProminent:
            if #available(iOS 15.0, macOS 12.0, *) {
                content.buttonStyle(.borderedProminent)
            } else {
                content.buttonStyle(.automatic)
            }
        }
    }
}
