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
import OSLog
import JudoModel

public extension Judo {

    struct View: SwiftUI.View {

        struct Setup {
            var viewData: ViewData
            var component: MainComponent
            var bindings: [String: ComponentBinding]
        }

        private struct ElementView: SwiftUI.View {
            @ObservedObject var element: Element
            let viewSetup: Setup

            init(element: Element, viewSetup: Setup) {
                self.element = element
                self.viewSetup = viewSetup
            }

            var body: some SwiftUI.View {
                if let component = element as? MainComponent {
                    MainComponentView(component: component, userBindings: viewSetup.bindings)
                } else if let layer = element as? Layer {
                    LayerView(layer: layer)
                }
            }
        }

        private var viewSetup: Setup?

        public init(_ fileName: String, bundle: Bundle = .main, component componentName: String? = nil, properties: [String: Any] = [:]) {
            let resourceName = (fileName as NSString).deletingPathExtension
            var resourceExtension = (fileName as NSString).pathExtension.lowercased()


            // Ensure that we are only looking to open Judo files
            if !resourceExtension.isEmpty, resourceExtension != "judo" {
                logger.error("Tried to load unsupported file format \(resourceExtension)")
                return
            } else if resourceExtension.isEmpty {
                resourceExtension = "judo"
            }

            let resourcePath = bundle.path(forResource: resourceName, ofType: resourceExtension)

            guard let resourcePath = resourcePath else {
                logger.error("Unable to find Judo view file to load \"\(resourceName).\(resourceExtension)\" in bundle \(bundle.bundleIdentifier!)")
                return
            }

            do {
                let viewData = try Loader.loadViewData(at: resourcePath)

                let viewComponents = viewData.documentData.nodes.compactMap { $0 as? MainComponent}
                let foundComponent: MainComponent?
                if componentName == nil {
                    foundComponent = viewComponents.first
                } else if let componentName {
                    foundComponent = viewComponents.first(where: { $0.name == componentName })
                } else {
                    foundComponent = nil
                }

                guard let foundComponent = foundComponent else {
                    logger.error("Can't find Judo Component to load")
                    return
                }

                viewSetup = Setup(
                    viewData: viewData,
                    component: foundComponent,
                    bindings: convert(properties)
                )
            } catch {
                logger.error("Failed to load View from \(fileName)")
            }

        }

        public init(fileURL: URL, component componentName: String? = nil, properties: [String: Any] = [:]) {
            let resourcePath = fileURL.path
            do {
                let viewData = try Loader.loadViewData(at: resourcePath)

                let viewComponents = viewData.documentData.nodes.compactMap { $0 as? MainComponent}

                let foundComponent: MainComponent?
                if componentName == nil {
                    foundComponent = viewComponents.first
                } else if let componentName {
                    foundComponent = viewComponents.first(where: { $0.name == componentName })
                } else {
                    foundComponent = nil
                }

                guard let foundComponent = foundComponent else {
                    logger.error("Can't find Judo Component to load")
                    return
                }

                viewSetup = Setup(
                    viewData: viewData,
                    component: foundComponent,
                    bindings: convert(properties)
                )
            } catch {
                logger.error("Failed to load View from \(fileURL)")
            }
        }

        public var body: some SwiftUI.View {
            if let viewSetup = viewSetup {
                ElementView(element: viewSetup.component, viewSetup: viewSetup)
                    .environmentObject(viewSetup.viewData.localizations)
                    .environmentObject(viewSetup.viewData.importedFonts)
                    .environmentObject(viewSetup.viewData.documentData)
                    .environmentObject(viewSetup.viewData.assets)
                    .id(viewSetup.bindings.mapValues(\.value))
            } else {
                NotFoundView()
            }
        }

        struct NotFoundView: SwiftUI.View {
            @Environment(\.colorScheme) private var colorScheme
            @Environment(\.displayScale) private var displayScale

            var body: some SwiftUI.View {
                SwiftUI.Image(packageResource: assetName, ofType: "png")
            }

            private var assetName: String {
                var name = "404"
                if colorScheme == .dark {
                    name += "-dark"
                }
                if displayScale > 1 {
                    name += "@2x"
                }
                return name
            }
        }
    }
}

// MARK: - Custom Actions

extension Judo.View {
    public func on(_ identifier: CustomActionIdentifier, handler: @escaping ([String: Any]) -> Void) -> Judo.ActionModifiedContent<Self> {
        Judo.ActionModifiedContent(identifier: identifier, handler: ActionHandler(handler: handler), content: self)
    }
}

extension Judo.ActionModifiedContent {
    public func on(_ identifier: CustomActionIdentifier, handler: @escaping ([String: Any]) -> Void) -> Judo.ActionModifiedContent<Self> {
        Judo.ActionModifiedContent(identifier: identifier, handler: ActionHandler(handler: handler), content: self)
    }
}

extension Judo {

    public struct ActionModifiedContent<Content: SwiftUI.View>: SwiftUI.View {
        @Environment(\.customActions) private var customActions
        private let identifier: CustomActionIdentifier
        private let handler: ActionHandler<[String: Any]>
        private let content: Content

        init(identifier: CustomActionIdentifier, handler: ActionHandler<[String: Any]>, content: Content) {
            self.identifier = identifier
            self.handler = handler
            self.content = content
        }

        public var body: some SwiftUI.View {
            content.environment(
                \.customActions,
                 customActions.merging([identifier: handler], uniquingKeysWith: {(_, new) in new })
            )
        }
    }

}

/// Convert user provided properties (Any), to corresponding ComponentBinding
private func convert(_ properties: [String: Any]) -> [String: ComponentBinding] {
    var result: [String: ComponentBinding] = [:]

    for (key, anyValue) in properties {
        switch anyValue {
        case let value as IntegerLiteralType:
            result[key] = ComponentBinding(value: Property.Value(integerLiteral: value))
        case let bindingValue as Binding<Int>:
            let propertyValueBinding = Binding {
                MainComponent.Properties.Value.number(Double(bindingValue.wrappedValue))
            } set: { newValue in
                if case .number(let value) = newValue {
                    bindingValue.wrappedValue = Int(value)
                }
            }
            result[key] = ComponentBinding(binding: propertyValueBinding)
        case let value as FloatLiteralType:
            result[key] = ComponentBinding(value: Property.Value(floatLiteral: value))
        case let bindingValue as Binding<Double>:
            let propertyValueBinding = Binding {
                MainComponent.Properties.Value.number(bindingValue.wrappedValue)
            } set: { newValue in
                if case .number(let value) = newValue {
                    bindingValue.wrappedValue = value
                }
            }
            result[key] = ComponentBinding(binding: propertyValueBinding)
        case let value as BooleanLiteralType:
            result[key] = ComponentBinding(value: Property.Value(booleanLiteral: value))
        case let bindingValue as Binding<Bool>:
            let propertyValueBinding = Binding {
                MainComponent.Properties.Value.boolean(bindingValue.wrappedValue)
            } set: { newValue in
                if case .boolean(let value) = newValue {
                    bindingValue.wrappedValue = value
                }
            }
            result[key] = ComponentBinding(binding: propertyValueBinding)
        case let value as StringLiteralType:
            result[key] = ComponentBinding(value: Property.Value(stringLiteral: value))
        case let bindingValue as Binding<String>:
            let propertyValueBinding = Binding {
                MainComponent.Properties.Value.text(bindingValue.wrappedValue)
            } set: { newValue in
                if case .text(let value) = newValue {
                    bindingValue.wrappedValue = value
                }
            }
            result[key] = ComponentBinding(binding: propertyValueBinding)
        case let value as SwiftUI.Image:
            result[key] = ComponentBinding(value: Property.Value.image(.inline(image: value)))
        case let value as UIImage:
            let image = SwiftUI.Image(uiImage: value)
            result[key] = ComponentBinding(value: Property.Value.image(.inline(image: image)))
        default:
            logger.warning("Invalid value for property \"\(key)\". Property unused.")
            break
        }
    }

    return result
}
