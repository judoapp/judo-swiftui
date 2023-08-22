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

struct ButtonView: SwiftUI.View {
    @ObservedObject var button: JudoModel.Button

    var body: some SwiftUI.View {
        if #available(iOS 15.0, *) {
            ButtonWithRole(
                actions: button.actions,
                role: button.role.swiftUIValue,
                content: content
            )
        } else {
            ButtonWithoutRole(
                actions: button.actions,
                content: content
            )
        }
    }

    private var content: some SwiftUI.View {
        ForEach(button.children.allOf(type: Layer.self)) {
            LayerView(layer: $0)
        }
    }
}

private struct ButtonWithoutRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button {
            for action in actions {
                switch action {
                case is JudoModel.DismissAction:
                    presentationMode.wrappedValue.dismiss()

                case let action as JudoModel.OpenURLAction:
                    if let urlString = action.url.resolve(data: data, componentState: componentState),
                       let url = URL(string: urlString) {
                        openURL(url)
                    }

                case is JudoModel.RefreshAction:
                    logger.info("Refresh is unavailable on iOS 14")
                    assertionFailure("Refresh is unavailable on iOS 14")
                    break

                case let action as CustomAction:
                    guard let resolvedValue = action.identifier.resolve(data: data, componentState: componentState) else {
                        continue
                    }
                    
                    let identifier = CustomActionIdentifier(resolvedValue)
                    
                    let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                        if let textValue = parameter.textValue {
                            let resolvedValue = textValue.resolve(data: data, componentState: componentState)
                            partialResult[parameter.key] = resolvedValue
                        } else if let numberValue = parameter.numberValue {
                            if let resolvedValue = numberValue.resolve(data: data, componentState: componentState) {
                                partialResult[parameter.key] = resolvedValue
                            }
                        } else if let booleanValue = parameter.booleanValue {
                            let resolvedValue = booleanValue.resolve(data: data, componentState: componentState)
                            partialResult[parameter.key] = resolvedValue
                        }
                    })
                    
                    customActions[identifier]?(parameters)

                case let action as PropertyAction:
                    if let propertyName = action.propertyName {
                        switch action {
                        case let action as SetPropertyAction:
                            if let textValue = action.textValue {
                                if let resolvedValue = textValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .text(resolvedValue)
                                }
                            } else if let numberValue = action.numberValue {
                                if let resolvedValue = numberValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .number(resolvedValue)
                                }
                            } else if let booleanValue = action.booleanValue {
                                if let resolvedValue = booleanValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                                }
                            } else if let imageValue = action.imageValue {
                                if let resolvedValue = imageValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .image(resolvedValue)
                                }
                            }
                        case is TogglePropertyAction:
                            if case .boolean(let value) = componentState.bindings[propertyName]?.value {
                                componentState.bindings[propertyName]?.value = .boolean(!value)
                            } else {
                                assertionFailure("Unexpected binding type")
                            }
                        case let action as IncrementPropertyAction:
                            if case .number(let value) = componentState.bindings[propertyName]?.value,
                               let resolvedByValue = action.value.resolve(data: data, componentState: componentState)
                            {
                                componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                            } else {
                                assertionFailure("Unexpected binding")
                            }
                        case let action as DecrementPropertyAction:
                            if case .number(let value) = componentState.bindings[propertyName]?.value,
                               let resolvedByValue = action.value.resolve(data: data, componentState: componentState)
                            {
                                componentState.bindings[propertyName]?.value = .number(value - resolvedByValue)
                            } else {
                                assertionFailure("Unexpected binding")
                            }
                        default:
                            assertionFailure("Unexpected action")
                        }
                    }
                default:
                    assertionFailure("Unexpected action")
                }
            }
        } label: {
            content
        }
    }
}

@available(iOS 15.0, *)
private struct ButtonWithRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]
    let role: SwiftUI.ButtonRole?
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button(role: role) {
            for action in actions {
                switch action {
                case is JudoModel.DismissAction:
                    dismiss()

                case let action as JudoModel.OpenURLAction:
                    if let urlString = action.url.resolve(data: data, componentState: componentState),
                       let url = URL(string: urlString) {
                        openURL(url)
                    }

                case is JudoModel.RefreshAction:
                    Task {
                        await refresh?()
                    }

                case let action as CustomAction:
                    guard let resolvedValue = action.identifier.resolve(data: data, componentState: componentState) else {
                        continue
                    }
                    
                    let identifier = CustomActionIdentifier(resolvedValue)
                    
                    let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                        if let textValue = parameter.textValue {
                            let resolvedValue = textValue.resolve(data: data, componentState: componentState)
                            partialResult[parameter.key] = resolvedValue
                        } else if let numberValue = parameter.numberValue {
                            if let resolvedValue = numberValue.resolve(data: data, componentState: componentState) {
                                partialResult[parameter.key] = resolvedValue
                            }
                        } else if let booleanValue = parameter.booleanValue {
                            let resolvedValue = booleanValue.resolve(data: data, componentState: componentState)
                            partialResult[parameter.key] = resolvedValue
                        }
                    })
                    
                    customActions[identifier]?(parameters)
                case let action as PropertyAction:
                    if let propertyName = action.propertyName {
                        switch action {
                        case let action as SetPropertyAction:
                            if let textValue = action.textValue {
                                if let resolvedValue = textValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .text(resolvedValue)
                                }
                            } else if let numberValue = action.numberValue {
                                if let resolvedValue = numberValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .number(resolvedValue)
                                }
                            } else if let booleanValue = action.booleanValue {
                                if let resolvedValue = booleanValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                                }
                            } else if let imageValue = action.imageValue {
                                if let resolvedValue = imageValue.resolve(data: data, componentState: componentState) {
                                    componentState.bindings[propertyName]?.value = .image(resolvedValue)
                                }
                            }
                        case is TogglePropertyAction:
                            if case .boolean(let value) = componentState.bindings[propertyName]?.value {
                                componentState.bindings[propertyName]?.value = .boolean(!value)
                            } else {
                                assertionFailure("Unexpected binding type")
                            }
                        case let action as IncrementPropertyAction:
                            if case .number(let value) = componentState.bindings[propertyName]?.value,
                               let resolvedByValue = action.value.resolve(data: data, componentState: componentState)
                            {
                                componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                            } else {
                                assertionFailure("Unexpected binding")
                            }
                        case let action as DecrementPropertyAction:
                            if case .number(let value) = componentState.bindings[propertyName]?.value,
                               let resolvedByValue = action.value.resolve(data: data, componentState: componentState)
                            {
                                componentState.bindings[propertyName]?.value = .number(value - resolvedByValue)
                            } else {
                                assertionFailure("Unexpected binding")
                            }
                        default:
                            assertionFailure("Unexpected action")
                        }
                    }
                default:
                    assertionFailure("Unexpected action")
                }
            }
        } label: {
            content
        }
    }
}
