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
import JudoDocument

final class ComponentState: ObservableObject {
    @Published var bindings: [String: ComponentBinding]
    
    var propertyValues: [String: PropertyValue] {
        bindings.reduce(into: [String: PropertyValue]()) { partialResult, element in
            partialResult[element.key] = element.value.value
        }
    }

    init(propertyValues: [String: PropertyValue], overrides: Overrides, data: Any?, fetchedImage: SwiftUI.Image?, parentState: ComponentState?) {
        var result = propertyValues.mapValues {
            ComponentBinding(value: $0)
        }
        
        propertyValues.forEach { (key, value) in
            switch (value, overrides[key]) {
            case (.text, .text(let textValue)):
                if case .property(let propertyName) = textValue.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = textValue.forceResolve(
                        propertyValues: propertyValues,
                        data: data
                    )
                    
                    result[key] = ComponentBinding(value: .text(resolvedValue))
                }
            case (.number(let defaultValue), .number(let numberValue)):
                if case .property(let propertyName) = numberValue.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = numberValue.resolve(
                        propertyValues: propertyValues,
                        data: data
                    )
                    result[key] = ComponentBinding(value: .number(resolvedValue ?? defaultValue))
                }
            case (.boolean, .boolean(let booleanValue)):
                if case .property(let propertyName) = booleanValue.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = booleanValue.forceResolve(
                        propertyValues: propertyValues,
                        data: data
                    )
                    result[key] = ComponentBinding(value: .boolean(resolvedValue))
                }
            case (.image, .image(let value)):
                if case .property(let propertyName) = value.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = value.forceResolve(
                        propertyValues: propertyValues,
                        data: data,
                        fetchedImage: fetchedImage
                    )
                    
                    result[key] = ComponentBinding(value: .image(resolvedValue))
                }
            case (.component(let defaultValue), .component(let value)):
                if case .property(let propertyName) = value.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = value.resolve(
                        propertyValues: propertyValues,
                        data: data
                    )
                    
                    result[key] = ComponentBinding(value: .component(resolvedValue ?? defaultValue))
                }

            case (.video, .video(let videoValue)):
                if case .property(let propertyName) = videoValue.binding, let parentState, parentState.bindings.keys.contains(propertyName) {
                    result[key] = ComponentBinding(binding: Binding {
                        parentState.bindings[propertyName]!.value
                    } set: { newValue in
                        parentState.bindings[propertyName]!.value = newValue
                    })
                } else {
                    let resolvedValue = videoValue.forceResolve(
                        propertyValues: propertyValues,
                        data: data
                    )

                    result[key] = ComponentBinding(value: .video(resolvedValue))
                }
            default:
                break
            }
        }

        self.bindings = result
    }
    
    init(propertyValues: [String: PropertyValue]) {
        self.bindings = propertyValues.mapValues({ ComponentBinding(value: $0) })
    }

    init(bindings: [String: ComponentBinding]) {
        self.bindings = bindings
    }
}

struct ComponentBinding {
    private var ownedValue: PropertyValue?
    private var binding: Binding<PropertyValue>?

    var value: PropertyValue {
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

    init(value: PropertyValue) {
        self.ownedValue = value
    }

    init(binding: Binding<PropertyValue>) {
        self.binding = binding
    }
}
