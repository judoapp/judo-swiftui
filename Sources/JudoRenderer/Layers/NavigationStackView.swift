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

struct NavigationStackView: SwiftUI.View {

    var navigationStack: JudoDocument.NavigationStackLayer

    var body: some SwiftUI.View {
        if #available(iOS 16.0, *) {
            NavigationStack_iOS16_View(navigationStack: navigationStack)
        } else {
            NavigationStack_Legacy_View(navigationStack: navigationStack)
        }
    }
}

@available(iOS 16.0, *)
private struct NavigationStack_iOS16_View: View {
    var navigationStack: JudoDocument.NavigationStackLayer

    var body: some SwiftUI.View {
        NavigationStack {
            SwiftUI.VStack(spacing: 0) {
                ForEach(navigationStack.children, id: \.id
                ) {
                    NodeView(node: $0)
                }
            }
        }
    }
}


private struct NavigationStack_Legacy_View: View {
    var navigationStack: JudoDocument.NavigationStackLayer

    var body: some SwiftUI.View {
        NavigationView {
            SwiftUI.VStack(spacing: 0) {
                ForEach(navigationStack.children, id: \.id
                ) {
                    NodeView(node: $0)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
