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

struct ToolbarBackgroundVisibilityViewModifier: SwiftUI.ViewModifier {
    @ObservedObject var modifier: ToolbarBackgroundVisibilityModifier

    func body(content: Content) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {
            content
                .modifierIf(modifier.bars.isEmpty) {
                    content.toolbarBackground(modifier.visibility.swiftUIValue)
                }
                .modifierIf(modifier.bars.contains(.tabBar)) {
                    content.toolbarBackground(modifier.visibility.swiftUIValue, for: .tabBar)
                }
                .modifierIf(modifier.bars.contains(.navigationBar)) {
                    content.toolbarBackground(modifier.visibility.swiftUIValue, for: .navigationBar)
                }
        } else {
            content
                .introspectNavigationController { navigationController in
                    switch modifier.visibility {
                    case .visible:
                        if modifier.bars.contains(.navigationBar) {
                            // Need to know the color from ToolbarBackgroundColorViewModifier since it's not yet set at this point
                            DispatchQueue.main.async {
                                let navBarAppearance = navigationController.navigationBar.standardAppearance
                                navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
                                if #available(iOS 15.0, *) {
                                    navigationController.navigationBar.compactScrollEdgeAppearance = navBarAppearance
                                }
                            }
                        }
                    case .hidden:
                        if modifier.bars.contains(.navigationBar) {
                            DispatchQueue.main.async {
                                let navBarAppearance = navigationController.navigationBar.standardAppearance
                                navBarAppearance.configureWithTransparentBackground()
                                navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
                                if #available(iOS 15.0, *) {
                                    navigationController.navigationBar.compactScrollEdgeAppearance = navBarAppearance
                                }
                            }
                        }
                    case .automatic:
                        break
                    }
                }
        }
    }
}

@available(iOS 15.0, *)
private extension JudoModel.Visibility {
    var swiftUIValue: SwiftUI.Visibility {
        switch self {
        case .visible:
            return .visible
        case .automatic:
            return .automatic
        case .hidden:
            return .hidden
        }
    }
}
