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
                    properties: componentState.properties,
                    data: data
                )

                if let url = URL(string: urlString) {
                    openURL?(url)
                }

            case is JudoDocument.RefreshAction:
                refresh?()

            case let action as CustomAction:
                let identifier = action.identifier.forceResolve(
                    properties: componentState.properties,
                    data: data
                )
                
                let name = ActionName(identifier)

                let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                    if let textValue = parameter.textValue {
                        let resolvedValue = textValue.forceResolve(
                            properties: componentState.properties,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let numberValue = parameter.numberValue {
                        let resolvedValue = numberValue.forceResolve(
                            properties: componentState.properties,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let booleanValue = parameter.booleanValue {
                        let resolvedValue = booleanValue.forceResolve(
                            properties: componentState.properties,
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
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .text(resolvedValue)
                        } else if let numberValue = action.numberValue {
                            let resolvedValue = numberValue.forceResolve(
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(resolvedValue)
                        } else if let booleanValue = action.booleanValue {
                            let resolvedValue = booleanValue.forceResolve(
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                        } else if let imageValue = action.imageValue {
                            let resolvedValue = imageValue.forceResolve(
                                properties: componentState.properties,
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
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                        } else {
                            assertionFailure("Unexpected binding")
                        }
                    case let action as DecrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                properties: componentState.properties,
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
                    properties: componentState.properties,
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
                    properties: componentState.properties,
                    data: data
                )
                
                let name = ActionName(identifier)

                let parameters: [String: Any] = action.parameters.reduce(into: [:], { partialResult, parameter in
                    if let textValue = parameter.textValue {
                        let resolvedValue = textValue.forceResolve(
                            properties: componentState.properties,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let numberValue = parameter.numberValue {
                        let resolvedValue = numberValue.forceResolve(
                            properties: componentState.properties,
                            data: data
                        )

                        partialResult[parameter.key] = resolvedValue
                    } else if let booleanValue = parameter.booleanValue {
                        let resolvedValue = booleanValue.forceResolve(
                            properties: componentState.properties,
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
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .text(resolvedValue)
                        } else if let numberValue = action.numberValue {
                            let resolvedValue = numberValue.forceResolve(
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(resolvedValue)
                        } else if let booleanValue = action.booleanValue {
                            let resolvedValue = booleanValue.forceResolve(
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .boolean(resolvedValue)
                        } else if let imageValue = action.imageValue {
                            let resolvedValue = imageValue.forceResolve(
                                properties: componentState.properties,
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
                                properties: componentState.properties,
                                data: data
                            )

                            componentState.bindings[propertyName]?.value = .number(value + resolvedByValue)
                        } else {
                            assertionFailure("Unexpected binding")
                        }
                    case let action as DecrementPropertyAction:
                        if case .number(let value) = componentState.bindings[propertyName]?.value {
                            let resolvedByValue = action.value.forceResolve(
                                properties: componentState.properties,
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
