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
        }

        private var viewSetup: Setup?

        public init(_ fileName: String, bundle: Bundle = .main, component componentName: String? = nil, properties: MainComponent.Properties = [:]) {
            let resourceName = (fileName as NSString).deletingPathExtension
            var resourceExtension = (fileName as NSString).pathExtension

            // Search for a filename with and without ".judo" filename extension
            var resourcePath = bundle.path(forResource: resourceName, ofType: resourceExtension)
            if resourcePath == nil, resourceExtension.isEmpty {
                resourceExtension = "judo"
                resourcePath = bundle.path(forResource: resourceName, ofType: resourceExtension)
            }

            guard let resourcePath = resourcePath else {
                logger.error("Unable to find Judo view file to load \"\(resourceName).\(resourceExtension)\" in bundle \(bundle.bundleIdentifier!)")
                assertionFailure("Can't find requested Judo View file to load in bundle \(bundle.bundleIdentifier!)")
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
                    assertionFailure("Can't find Judo Component to load")
                    return
                }

                foundComponent.properties = foundComponent.properties.merging(properties, uniquingKeysWith: {(_, new) in new })

                viewSetup = Setup(viewData: viewData, component: foundComponent)
            } catch {
                logger.error("Failed to load View from \(fileName)")
                assertionFailure("Failed to load View from \(fileName)")
            }

        }

        public init(fileURL: URL, component componentName: String? = nil, properties: MainComponent.Properties = [:]) {
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
                    assertionFailure("Can't find Judo Component to load")
                    return
                }

                foundComponent.properties = foundComponent.properties.merging(properties, uniquingKeysWith: {(_, new) in new })

                viewSetup = Setup(viewData: viewData, component: foundComponent)
            } catch {
                logger.error("Failed to load View from \(fileURL)")
                assertionFailure("Failed to load View from \(fileURL)")
            }
        }

        public var body: some SwiftUI.View {
            if let viewSetup = viewSetup {
                ElementView(element: viewSetup.component)
                    .environmentObject(viewSetup.viewData.localizations)
                    .environmentObject(viewSetup.viewData.importedFonts)
                    .environmentObject(viewSetup.viewData.documentData)
                    .environmentObject(viewSetup.viewData.assets)
            } else {
                EmptyView()
            }
        }
    }

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
