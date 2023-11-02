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
import Introspect

struct ToolbarColorSchemeViewModifier: SwiftUI.ViewModifier {
    var modifier: ToolbarColorSchemeModifier

    func body(content: Content) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {

            content
                .modifierIf(modifier.bars.isEmpty) {
                    content.toolbarColorScheme(modifier.colorScheme.swiftUIValue)
                }
                .modifierIf(modifier.bars.contains(.tabBar)) {
                    content.toolbarColorScheme(modifier.colorScheme.swiftUIValue, for: .tabBar)
                }
                .modifierIf(modifier.bars.contains(.navigationBar)) {
                    content.toolbarColorScheme(modifier.colorScheme.swiftUIValue, for: .navigationBar)
                }
        } else {
            content
                .introspectNavigationController { navigationController in
                    if modifier.bars.contains(.navigationBar) {
                        let navBarAppearance = navigationController.navigationBar.standardAppearance

                        switch modifier.colorScheme {
                        case .dark:
                            var attributes = navBarAppearance.titleTextAttributes
                            attributes[.foregroundColor] = UIColor.white
                            navBarAppearance.titleTextAttributes = attributes
                        case .light:
                            var attributes = navBarAppearance.titleTextAttributes
                            attributes[.foregroundColor] = UIColor.label
                            navBarAppearance.titleTextAttributes = attributes
                        }
                        navBarAppearance.largeTitleTextAttributes = navBarAppearance.largeTitleTextAttributes
                    }
                }
        }

    }
}

private extension JudoDocument.ColorScheme {
    var swiftUIValue: SwiftUI.ColorScheme {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}
