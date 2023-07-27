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
import Introspect

struct ToolbarBackgroundColorViewModifier: SwiftUI.ViewModifier {
    @ObservedObject var modifier: ToolbarBackgroundColorModifier

    func body(content: Content) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {
            RealizeColor(modifier.color, content: { realizedColor in
                switch modifier.bars {
                case .navigationBar:
                    content.toolbarBackground(realizedColor, for: .navigationBar)
                case .tabBar:
                    content.toolbarBackground(realizedColor, for: .tabBar)
                case .all:
                    content.toolbarBackground(realizedColor, for: .navigationBar, .tabBar)
                default:
                    content
                }
            })
        } else {
            RealizeColor(modifier.color, cocoaContent: { realizedColor in
                content
                    .introspectNavigationController { navigationController in
                        if modifier.bars.contains(.navigationBar) {
                            let navBarAppearance = navigationController.navigationBar.standardAppearance
                            navBarAppearance.backgroundColor = realizedColor
                            navigationController.navigationBar.standardAppearance = navBarAppearance
                            navigationController.navigationBar.compactAppearance = navBarAppearance
                        }
                    }
            })
        }
    }
}
