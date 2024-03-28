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
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data
    @Environment(\.document) private var document

    var componentInstance: ComponentInstanceLayer

    var body: some View {
        /// Special handling for custom views since resolve only works for property values.
        if case .property(let propertyName) = componentInstance.value.binding,
            let view = componentBindings[propertyName]?.wrappedValue as? any View {
            AnyView(view)
        } else if let mainComponent {
            MainComponentView(
                mainComponent: mainComponent,
                overrides: componentInstance.overrides
            )
        }
    }

    private var mainComponent: MainComponentNode? {
        let mainComponentID = componentInstance.value.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
        
        let node = document.allNodes.first(where: { $0.id == mainComponentID })
        return node as? MainComponentNode
    }
}
