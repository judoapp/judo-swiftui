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

struct ToolbarItemViewModifier: SwiftUI.ViewModifier {

    @ObservedObject var modifier: ToolbarItemModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    if #available(iOS 15.0, *) {
                        ModernToolbarItemButtonView(modifier: modifier)
                    } else {
                        ToolbarItemButtonView(modifier: modifier)
                    }
                }
            }
    }

    var placement: SwiftUI.ToolbarItemPlacement {
        switch modifier.placement {
            // Leading Items
        case .leading:
            return .navigationBarLeading
        case .cancellation:
            return .cancellationAction
        case .navigation:
            return .navigation

            // Center Items
        case .principal:
            return .principal

            // Trailing Items
        case .automatic:
            return .automatic
        case .trailing:
            return .navigationBarTrailing
        case .primary:
            return .primaryAction
        case .confirmation:
            return .confirmationAction
        case .destruction:
            return .destructiveAction
        case .secondary:
            if #available(iOS 16.0, *) {
                return .secondaryAction
            } else {
                return .primaryAction
            }
        }
    }
}


@available(iOS 15.0, *)
private struct ModernToolbarItemButtonView: SwiftUI.View {
    @Environment(\.refresh) private var refresh
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let modifier: ToolbarItemModifier

    var body: some SwiftUI.View {
        Button {
            actions(modifier.actions)
        } label: {
            LabelView(modifier: modifier)
        }
    }

    private func actions(_ actions: [JudoModel.Action]) {
        for action in actions {
            switch action {
            case is JudoModel.DismissAction:
                dismiss()

            case let action as JudoModel.OpenURLAction:
                if let url = URL(string: action.url.description) {
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
                processPropertyAction(action, componentState: componentState, data: data)
                
            default:
                assertionFailure("Unexpected action")
            }
        }
    }
}

private struct ToolbarItemButtonView: SwiftUI.View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let modifier: ToolbarItemModifier

    var body: some SwiftUI.View {
        Button {
            actions(modifier.actions)
        } label: {
            LabelView(modifier: modifier)
        }
    }

    private func actions(_ actions: [JudoModel.Action]) {
        for action in actions {
            switch action {
            case is JudoModel.DismissAction:
                presentationMode.wrappedValue.dismiss()

            case let action as JudoModel.OpenURLAction:
                if let url = URL(string: action.url.description) {
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
                processPropertyAction(action, componentState: componentState, data: data)
            
            default:
                assertionFailure("Unexpected action")
            }
        }
    }
}

private func processPropertyAction(_ action: JudoModel.PropertyAction, componentState: ComponentState, data: Any?) {
    guard let propertyName = action.propertyName else {
        return
    }
    
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

private struct LabelView: SwiftUI.View {
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let modifier: ToolbarItemModifier

    var body: some SwiftUI.View {
        if let icon = modifier.icon, let title = title {
            SwiftUI.Label(title, systemImage: icon.symbolName)
        } else if let icon = modifier.icon {
            SwiftUI.Image(systemName: icon.symbolName)
        } else if let title = title {
            SwiftUI.Text(title)
        }
    }

    private var title: String? {
        try? modifier.title?.description.evaluatingExpressions(
            data: data,
            properties: componentState.properties
        )
    }
}
