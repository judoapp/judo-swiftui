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
            var properties: MainComponent.Properties
        }

        private struct ElementView: SwiftUI.View {
            @ObservedObject var element: Element

            var body: some SwiftUI.View {
                if let component = element as? MainComponent {
                    MainComponentView(component: component)
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
                    properties: convert(properties)
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
                    properties: convert(properties)
                )
            } catch {
                logger.error("Failed to load View from \(fileURL)")
            }
        }

        public var body: some SwiftUI.View {
            if let viewSetup = viewSetup {
                ElementView(element: viewSetup.component)
                    .environmentObject(viewSetup.viewData.localizations)
                    .environmentObject(viewSetup.viewData.importedFonts)
                    .environmentObject(viewSetup.viewData.documentData)
                    .environmentObject(viewSetup.viewData.assets)
                    .transformEnvironment(\.properties) { properties in
                        properties.merge(viewSetup.properties, uniquingKeysWith: {(_, new) in new })
                    }
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

public extension Judo {
    typealias CustomActionIdentifier = JudoModel.CustomActionIdentifier
}

public extension Judo.View {

    func on(_ identifier: CustomActionIdentifier, handler: @escaping (UserInfo) -> Void) -> some SwiftUI.View {
        modifier(
            ActionViewModifier(
                identifier: identifier,
                handler: ActionHandler(handler: handler)
            )
        )
    }

    private struct ActionViewModifier: ViewModifier {
        @Environment(\.customActions) private var customActions
        private let identifier: CustomActionIdentifier
        private let handler: ActionHandler<UserInfo>

        init(identifier: CustomActionIdentifier, handler: ActionHandler<UserInfo>) {
            self.identifier = identifier
            self.handler = handler
        }

        func body(content: Content) -> some View {
            content.environment(
                \.customActions,
                 customActions.merging([identifier: handler], uniquingKeysWith: {(_, new) in new })
            )
        }
    }

}


private func convert(_ properties: [String: Any]) -> MainComponent.Properties {
    var result: MainComponent.Properties = [:]

    for (key, anyValue) in properties {
        switch anyValue {
        case let value as IntegerLiteralType:
            result[key] = Property.Value(integerLiteral: value)
        case let value as FloatLiteralType:
            result[key] = Property.Value(floatLiteral: value)
        case let value as BooleanLiteralType:
            result[key] = Property.Value(booleanLiteral: value)
        case let value as StringLiteralType:
            result[key] = Property.Value(stringLiteral: value)
        case let value as SwiftUI.Image:
            result[key] = Property.Value.image(.inline(image: value))
        case let value as UIImage:
            let image = SwiftUI.Image(uiImage: value)
            result[key] = Property.Value.image(.inline(image: image))
        default:
            logger.warning("Invalid value for property \"\(key)\". Property unused.")
            break
        }
    }

    return result
}
