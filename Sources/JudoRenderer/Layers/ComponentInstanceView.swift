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

/// A SwiftUI view for rendering a `ComponentInstance`.
struct ComponentInstanceView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @ObservedObject var componentInstance: ComponentInstance

    @Environment(\.data) private var data
    @Environment(\.fetchedImage) private var fetchedImage

    init(componentInstance: ComponentInstance) {
        self.componentInstance = componentInstance
    }

    var body: some SwiftUI.View {
        ForEach(orderedLayers) {
            LayerView(layer: $0)
        }
        .modifier(
            ZStackContentIfNeededModifier(for: orderedLayers)
        )
        .environmentObject(
            ComponentState(
                properties: mainComponent.properties,
                overrides: componentInstance.overrides,
                data: data,
                fetchedImage: fetchedImage,
                parentState: componentState
            )
        )
    }
    
    private var mainComponent: MainComponent {
        componentInstance.value.forceResolve(
            properties: componentState.properties,
            data: data
        )
    }
    
    private var orderedLayers: [Layer] {
        mainComponent.children.allOf(type: Layer.self).reversed()
    }
}
