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

enum Actions {
    @available(iOS 15.0, *)
    static func perform(
        actions: [Action],
        componentState: ComponentState,
        data: Any?, 
        actionHandlers: [ActionName: ActionHandler],
        dismiss: (() -> Void)?,
        openURL: ((URL) -> Void)?,
        refresh: (() -> Void)?
    ) {
        for action in actions {
            switch action {
            case is JudoDocument.DismissAction:
                dismiss?()

            case let action as JudoDocument.OpenURLAction:
                let urlString = action.url.forceResolve(
                    propertyValues: componentState.propertyValues,
                    data: data
                )

                if let url = URL(string: urlString) {
                    openURL?(url)
                }

            case is JudoDocument.RefreshAction:
                refresh?()

            case let action as CustomAction:
                let identifier = action.identifier.forceResolve(
                    propertyValues: componentState.propertyValues,
                    data: data
                )
                
                let name = ActionName(identifier)

                let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                    if let textValue = parameter.textValue {
                        let resolvedValue = textValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let numberValue = parameter.numberValue {
                        let resolvedValue = numberValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let booleanValue = parameter.booleanValue {
                        let resolvedValue = booleanValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    }
                })

                actionHandlers[name]?(parameters)
            case let action as PropertyAction:
                if let propertyName = action.propertyName {
                    switch action {
                    case let action as SetPropertyAction:
                        if let textValue = action.textValue {
                            let resolvedValue = textValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .text(resolvedValue)
                        } else if let numberValue = action.numberValue {
                            let resolvedValue = numberValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(resolvedValue)
                        } else if let booleanValue = action.booleanValue {
                            let resolvedValue = booleanValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                        } else if let imageValue = action.imageValue {
                            let resolvedValue = imageValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .image(resolvedValue)
                        }
                    case is TogglePropertyAction:
                        if case .boolean(let value) = componentState.bindings[propertyName]?.value {
                            componentState.bindings[propertyName]?.value = .boolean(!value)
                        } else {
                            assertionFailure("Unexpected binding type")
                        }
                    case let action as IncrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                        } else {
                            assertionFailure("Unexpected binding")
                        }
                    case let action as DecrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

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
    }

    static func perform(
        actions: [Action],
        componentState: ComponentState,
        data: Any?, 
        actionHandlers: [ActionName: ActionHandler],
        dismiss: (() -> Void)?,
        openURL: ((URL) -> Void)?
    ) {
        for action in actions {
            switch action {
            case is JudoDocument.DismissAction:
                dismiss?()

            case let action as JudoDocument.OpenURLAction:
                let urlString = action.url.forceResolve(
                    propertyValues: componentState.propertyValues,
                    data: data
                )

                if let url = URL(string: urlString) {
                    openURL?(url)
                }

            case is JudoDocument.RefreshAction:
                logger.info("Refresh is unavailable on iOS 14")
                assertionFailure("Refresh is unavailable on iOS 14")
                break

            case let action as CustomAction:
                let identifier = action.identifier.forceResolve(
                    propertyValues: componentState.propertyValues,
                    data: data
                )
                
                let name = ActionName(identifier)

                let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                    if let textValue = parameter.textValue {
                        let resolvedValue = textValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let numberValue = parameter.numberValue {
                        let resolvedValue = numberValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let booleanValue = parameter.booleanValue {
                        let resolvedValue = booleanValue.forceResolve(
                            propertyValues: componentState.propertyValues,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    }
                })

                actionHandlers[name]?(parameters)

            case let action as PropertyAction:
                if let propertyName = action.propertyName {
                    switch action {
                    case let action as SetPropertyAction:
                        if let textValue = action.textValue {
                            let resolvedValue = textValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .text(resolvedValue)
                        } else if let numberValue = action.numberValue {
                            let resolvedValue = numberValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(resolvedValue)
                        } else if let booleanValue = action.booleanValue {
                            let resolvedValue = booleanValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                        } else if let imageValue = action.imageValue {
                            let resolvedValue = imageValue.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .image(resolvedValue)
                        }
                    case is TogglePropertyAction:
                        if case .boolean(let value) = componentState.bindings[propertyName]?.value {
                            componentState.bindings[propertyName]?.value = .boolean(!value)
                        } else {
                            assertionFailure("Unexpected binding type")
                        }
                    case let action as IncrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                        } else {
                            assertionFailure("Unexpected binding")
                        }
                    case let action as DecrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                propertyValues: componentState.propertyValues,
                                data: data
                            )

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
    }
}
