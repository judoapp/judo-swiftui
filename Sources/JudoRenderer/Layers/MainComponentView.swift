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
import JudoModel
import OrderedCollections
import SwiftUI
import os.log

/// A SwiftUI view for rendering a `MainComponent`.
struct MainComponentView: SwiftUI.View {
    @ObservedObject var component: MainComponent
    @StateObject private var componentState: ComponentState

    /// Initialize with MainComponent and user provided bindings (parameters)
    init(component: MainComponent, userBindings: [String: ComponentBinding]) {
        self.component = component
        self._componentState = StateObject(
            wrappedValue: ComponentState(
                bindings: component.properties
                    .mapValues { ComponentBinding(value: $0) }
                    .merging(userBindings, uniquingKeysWith: { (_, new) in new })
                    .asDictionary()
            )
        )
    }
        
    var body: some SwiftUI.View {
        ForEach(orderedLayers) { layer in
            LayerView(layer: layer)
        }
        .modifier(
            /// On iOS 12 when content is wrapped in ZStack
            /// the TabView does not properly expand to full screen
            /// To workaround, we only wrap in ZStack if there's
            /// more than one layer on the root of the component
            ZStackContentIfNeededModifier(for: orderedLayers)
        )
        .environmentObject(componentState)
    }
    
    private var orderedLayers: [Layer] {
        component.children.allOf(type: Layer.self).reversed()
    }
}
