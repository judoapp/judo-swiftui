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
    @Environment(\.properties) private var properties
    @ObservedObject var componentInstance: ComponentInstance
    
    init(componentInstance: ComponentInstance) {
        self.componentInstance = componentInstance
    }
    
    var body: some SwiftUI.View {
        if let mainComponent = mainComponent {
            ContentView(
                mainComponent: mainComponent,
                overrides: componentInstance.overrides
            )
        }
    }

    private var mainComponent: MainComponent? {
        componentInstance.value.resolve(properties: properties)
    }
}

// Use a nested view that updates whenever the `MainComponent` changes.
private struct ContentView: SwiftUI.View {
    @EnvironmentObject private var localizations: DocumentLocalizations
    @Environment(\.data) private var data
    @Environment(\.fetchedImage) private var fetchedImage
    @Environment(\.properties) private var properties

    @ObservedObject var mainComponent: MainComponent
    let overrides: ComponentInstance.Overrides

    var body: some SwiftUI.View {
        ForEach(orderedLayers) {
            LayerView(layer: $0)
        }
        .modifier(
            ZStackContentIfNeededModifier(for: orderedLayers)
        )
        .environment(\.properties, resolvedProperties)
    }
    
    private var orderedLayers: [Layer] {
        mainComponent.children.allOf(type: Layer.self).reversed()
    }

    private var resolvedProperties: MainComponent.Properties {
        var result = mainComponent.properties

        mainComponent.properties.forEach { (key, value) in
            switch (value, overrides[key]) {
            case (.text, .text(let value)):
                let resolvedValue = value.resolve(
                    data: data,
                    properties: properties,
                    locale: Locale.preferredLocale,
                    localizations: localizations
                )

                result[key] = .text(resolvedValue)
            case (.number, .number(let value)):
                result[key] = .number(value)
            case (.boolean, .boolean(let value)):
                result[key] = .boolean(value)
            case (.image(let defaultValue), .image(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    fetchedImage: fetchedImage
                )
                
                result[key] = .image(resolvedValue ?? defaultValue)
            case (.component(let defaultValue), .component(let value)):
                let resolvedValue = value.resolve(
                    properties: properties
                )

                result[key] = .component(resolvedValue ?? defaultValue)
            default:
                break
            }
        }

        return result
    }
}
