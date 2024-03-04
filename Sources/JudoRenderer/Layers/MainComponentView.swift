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

/// A SwiftUI view for rendering a `MainComponentNode`.
struct MainComponentView: SwiftUI.View {
    var component: MainComponentNode
    @StateObject private var componentState: ComponentState

    /// Initialize with MainComponentNode and user provided bindings (parameters)
    init(component: MainComponentNode, userBindings: [String: ComponentBinding], userViews: [String: any View]) {
        self.component = component
        self._componentState = StateObject(
            wrappedValue: ComponentState(
                bindings: component.properties
                    .reduce(into: [:]) { partialResult, property in
                        partialResult[property.name] = ComponentBinding(property.value)
                    }
                    .merging(userBindings, uniquingKeysWith: { (_, new) in new }),
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
        component.children
    }
}
