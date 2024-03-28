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
    @Environment(\.data) private var data
    @Environment(\.document) private var document
    @Environment(\.fetchedImage) private var fetchedImage
    @Environment(\.componentBindings) private var componentBindings

    @State private var componentState: [String: Any] = [:]

    var mainComponent: MainComponentNode
    var overrides: Overrides = [:]
    var userProperties: [String: Any] = [:]

    init(mainComponent: MainComponentNode, userProperties: [String : Any]) {
        self.mainComponent = mainComponent
        self.userProperties = userProperties
    }

    init(mainComponent: MainComponentNode, overrides: Overrides) {
        self.mainComponent = mainComponent
        self.overrides = overrides
    }

    var body: some SwiftUI.View {
        ForEach(mainComponent.children, id: \.id) {
            NodeView(node: $0)
        }
        .environment(\.componentBindings, resolvedComponentBindings)
    }

    private var resolvedComponentBindings: ComponentBindings {
        mainComponent.properties.reduce(into: [:]) { partialResult, property in
            partialResult[property.name] = Binding(
                get: {
                    /// 1. Check if `componentState` has a value. This means a control (e.g. TextField, Toggle or Slider) has updated the value from it's default value. This takes precedent.
                    if let value = componentState[property.name] {
                        return value
                    }

                    /// 2. Check if the user has provided a value or binding to a value when initiating the JudoView.
                    switch (property.value, userProperties[property.name]) {
                    case (.number, let value as IntegerLiteralType):
                        return Double(value)
                    case (.number, let binding as Binding<Int>):
                        return Double(binding.wrappedValue)
                    case (.number, let value as FloatLiteralType):
                        return Double(value)
                    case (.number, let binding as Binding<Double>):
                        return binding.wrappedValue
                    case (.boolean, let value as BooleanLiteralType):
                        return Bool(value)
                    case (.boolean, let binding as Binding<Bool>):
                        return binding.wrappedValue
                    case (.text, let value as StringLiteralType):
                        return String(value)
                    case (.text, let binding as Binding<String>):
                        return binding.wrappedValue
                    case (.image, let value as SwiftUI.Image):
                        return ImageReference.inline(image: value)
                    case (.image, let value as UIImage):
                        let image = SwiftUI.Image(uiImage: value)
                        return ImageReference.inline(image: image)
                    case (.component, let value as any View):
                        return value
                    default:
                        break
                    }

                    /// 3. Check if the default value has been overridden
                    switch (property.value, overrides[property.name]) {
                    case (.text(let defaultValue), .text(let value)):
                        let resolvedValue = value.resolve(
                            propertyValues: componentBindings.propertyValues,
                            data: data,
                            fetchedImage: fetchedImage
                        )

                        return resolvedValue ?? defaultValue
                    case (.number(let defaultValue), .number(let value)):
                        let resolvedValue = value.resolve(
                            propertyValues: componentBindings.propertyValues,
                            data: data,
                            fetchedImage: fetchedImage
                        )

                        return resolvedValue ?? defaultValue
                    case (.boolean(let defaultValue), .boolean(let value)):
                        let resolvedValue = value.resolve(
                            propertyValues: componentBindings.propertyValues,
                            data: data,
                            fetchedImage: fetchedImage
                        )

                        return resolvedValue ?? defaultValue
                    case (.image(let defaultValue), .image(let value)):
                        let resolvedValue = value.resolve(
                            propertyValues: componentBindings.propertyValues,
                            data: data,
                            fetchedImage: fetchedImage
                        )

                        return resolvedValue ?? defaultValue
                    case (.component(let defaultValue), .component(let value)):
                        /// Special handling for custom views since resolve only works for property values.
                        if case .property(let propertyName) = value.binding,
                            let view = componentBindings[propertyName]?.wrappedValue as? any View {
                            return view
                        }

                        let resolvedValue = value.resolve(
                            propertyValues: componentBindings.propertyValues,
                            data: data,
                            fetchedImage: fetchedImage
                        )

                        return resolvedValue ?? defaultValue
                    default:
                        break
                    }

                    /// 4. Return the default value defined on the main component itself.
                    switch property.value {
                    case .text(let defaultValue):
                        return defaultValue
                    case .number(let defaultValue):
                        return defaultValue
                    case .boolean(let defaultValue):
                        return defaultValue
                    case .image(let defaultValue):
                        return defaultValue
                    case .component(let defaultValue):
                        return defaultValue
                    case .video(let defaultValue):
                        return defaultValue
                    case .computed(let defaultValue):
                        switch defaultValue {
                        case .text(let expression):
                            return expression
                        case .number(let expression):
                            return expression
                        case .boolean(let expression):
                            return expression
                        }
                    }
                },
                set: { newValue in
                    /// 1. Check if the user has supplied a binding
                    switch (property.value, userProperties[property.name]) {
                    case (.text, let binding as Binding<String>):
                        guard let value = newValue as? String else {
                            assertionFailure("Wrong value type—expected text")
                            break
                        }

                        binding.wrappedValue = value
                        return
                    case (.number, let binding as Binding<Int>):
                        guard let value = newValue as? Double else {
                            assertionFailure("Wrong value type—expected number")
                            break
                        }

                        binding.wrappedValue = Int(value)
                        return
                    case (.number, let binding as Binding<Double>):
                        guard let value = newValue as? Double else {
                            assertionFailure("Wrong value type—expected number")
                            break
                        }

                        binding.wrappedValue = value
                        return
                    case (.boolean, let binding as Binding<Bool>):
                        guard let value = newValue as? Bool else {
                            assertionFailure("Wrong value type—expected boolean")
                            break
                        }

                        binding.wrappedValue = value
                        return
                    default:
                        break
                    }

                    /// 2. Check if the property has been overridden with a binding
                    switch (property.value, overrides[property.name]) {
                    case (.text, .text(let variable)):
                        if case .property(let propertyName) = variable.binding, let binding = componentBindings[propertyName] {
                            guard let value = newValue as? String else {
                                assertionFailure("Wrong value type—expected text")
                                break
                            }

                            binding.wrappedValue = value
                            return
                        }
                    case (.number, .number(let variable)):
                        if case .property(let propertyName) = variable.binding, let binding = componentBindings[propertyName] {
                            guard let value = newValue as? Double else {
                                assertionFailure("Wrong value type—expected number")
                                break
                            }

                            binding.wrappedValue = value
                            return
                        }
                    case (.boolean, .boolean(let variable)):
                        if case .property(let propertyName) = variable.binding, let binding = componentBindings[propertyName] {
                            guard let value = newValue as? Bool else {
                                assertionFailure("Wrong value type—expected boolean")
                                break
                            }

                            binding.wrappedValue = value
                            return
                        }
                    default:
                        break
                    }

                    // 3. Update component state
                    componentState[property.name] = newValue
                }
            )
        }
    }
}
