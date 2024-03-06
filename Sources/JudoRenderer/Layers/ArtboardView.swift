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

import Combine
import JudoDocument
import OrderedCollections
import SwiftUI
import os.log

struct ArtboardView: SwiftUI.View {
    var artboard: ArtboardNode
    @StateObject private var componentState: ComponentState

    init(artboard: ArtboardNode, userBindings: [String: ComponentBinding], userViews: [String: any View]) {
        self.artboard = artboard
        self._componentState = StateObject(
            wrappedValue: ComponentState(
                bindings: userBindings,
                views: userViews
            )
        )
    }

    var body: some SwiftUI.View {
        ForEach(orderedNodes, id: \.id) { node in
            NodeView(node: node)
        }
        .environmentObject(componentState)
    }

    private var orderedNodes: [Node] {
        artboard.children
    }
}
