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

/// A SwiftUI view for rendering a `ComponentInstance`.
struct ComponentInstanceView: SwiftUI.View {
    @Environment(\.document) private var document
    @EnvironmentObject private var componentState: ComponentState
    var componentInstance: ComponentInstanceNode

    @Environment(\.data) private var data
    @Environment(\.fetchedImage) private var fetchedImage

    init(componentInstance: ComponentInstanceNode) {
        self.componentInstance = componentInstance
    }

    var body: some SwiftUI.View {
        ForEach(orderedNodes, id: \.id) {
            NodeView(node: $0)
        }
        .modifier(
            ZStackContentIfNeededModifier(for: orderedNodes)
        )
        .environmentObject(
            ComponentState(
                propertyValues: mainComponent?.properties.reduce(into: [:]) { partialResult, property in
                    partialResult[property.name] = property.value
                } ?? [:],
                overrides: componentInstance.overrides,
                data: data,
                fetchedImage: fetchedImage,
                parentState: componentState
            )
        )
    }
    
    private var mainComponent: MainComponentNode? {
        let mainComponentID = componentInstance.value.forceResolve(
            propertyValues: componentState.propertyValues,
            data: data
        )
        
        return document.children.first { node in
            switch node {
            case let mainComponent as MainComponentNode:
                return mainComponent.id == mainComponentID
            default:
                return false
            }
        } as? MainComponentNode
    }
    
    private var orderedNodes: [Node] {
        mainComponent?.children.reversed() ?? []
    }
}
