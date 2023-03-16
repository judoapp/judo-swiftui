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

struct TabItemViewModifier: SwiftUI.ViewModifier {
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties

    @ObservedObject var modifier: TabItemModifier

    public func body(content: Content) -> some SwiftUI.View {
        content
            .tabItem {
                switch (title, modifier.tabItem.icon) {
                case let (.some(title), nil):
                    SwiftUI.Text(title)
                case let (nil, .some(icon)):
                    SwiftUI.Image(systemName: icon.symbolName)
                case let (.some(title), .some(icon)):
                    Label(title, systemImage: icon.symbolName)
                default:
                    EmptyView()
                }
            }
    }

    private var title: String? {
        try? modifier.tabItem.title?.description.evaluatingExpressions(
            data: data,
            properties: properties
        )
    }
}
