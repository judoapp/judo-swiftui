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

import SwiftUI
import JudoModel

final class ComponentState: ObservableObject {
    @Published var bindings: [String: ComponentBinding]
    
    var properties: MainComponent.Properties {
        bindings.reduce(into: MainComponent.Properties()) { partialResult, element in
            partialResult[element.key] = element.value.value
        }
    }

    init(properties: MainComponent.Properties, overrides: ComponentInstance.Overrides, localizations: DocumentLocalizations, data: Any?, fetchedImage: SwiftUI.Image?, parentState: ComponentState?) {
        var result = properties.mapValues {
            ComponentBinding(value: $0)
        }.asDictionary()
        
        properties.forEach { (key, value) in
            switch (value, overrides[key]) {
            case (.text, .text(let textValue)):
                if case .property(let propertyName, _) = textValue, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = textValue.resolve(
                        data: data,
                        properties: properties,
                        locale: Locale.preferredLocale,
                        localizations: localizations
                    )
                    
                    result[key] = ComponentBinding(value: .text(resolvedValue))
                }
            case (.number(let defaultValue), .number(let numberValue)):
                if case .property(let propertyName) = numberValue, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = numberValue.resolve(
                        data: data,
                        properties: properties
                    )
                    result[key] = ComponentBinding(value: .number(resolvedValue ?? defaultValue))
                }
            case (.boolean, .boolean(let booleanValue)):
                if case .property(let propertyName) = booleanValue, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = booleanValue.resolve(
                        data: data,
                        properties: properties
                    )
                    result[key] = ComponentBinding(value: .boolean(resolvedValue))
                }
            case (.image(let defaultValue), .image(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    fetchedImage: fetchedImage
                )

                result[key] = ComponentBinding(value: .image(resolvedValue ?? defaultValue))
            case (.component(let defaultValue), .component(let value)):
                let resolvedValue = value.resolve(
                    properties: properties
                )

                result[key] = ComponentBinding(value: .component(resolvedValue ?? defaultValue))
            default:
                break
            }
        }

        self.bindings = result
    }
    
    init(properties: MainComponent.Properties) {
        self.bindings = properties.mapValues({ ComponentBinding(value: $0) }).asDictionary()
    }

    init(bindings: [String: ComponentBinding]) {
        self.bindings = bindings
    }
}

struct ComponentBinding {
    private var ownedValue: MainComponent.Properties.Value?
    private var binding: Binding<MainComponent.Properties.Value>?

    var value: MainComponent.Properties.Value {
        get {
            if let ownedValue {
                return ownedValue
            }

            if let binding {
                return binding.wrappedValue
            }

            fatalError()
        }

        set {
            if let binding {
                binding.wrappedValue = newValue
            } else {
                ownedValue = newValue
            }
        }
    }

    init(value: MainComponent.Properties.Value) {
        self.ownedValue = value
    }

    init(binding: Binding<MainComponent.Properties.Value>) {
        self.binding = binding
    }
}
