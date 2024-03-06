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

/// A SwiftUI view that is created from a Judo document.
///
/// You initialize a `JudoView` with a Judo document created with the Judo Mac app. The most common way to do this is to add the Judo document to your app's bundle and initialize the `JudoView` by passing it the file name.
///
/// ```swift
/// let myView = JudoView("MyFile")
/// ```
///
/// A `JudoView` conforms to the SwiftUI `View` protocol and can be used directly within the body of other SwiftUI views. SwiftUI view modifiers can also be applied to a `JudoView`.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         JudoView("MyFile")
///             .padding()
///             .opacity(0.5)
///     }
/// }
/// ```
///
/// To load a `JudoView` asynchronously, including from a remote server, see ``JudoAsyncView``.
public struct JudoView: View {
    private static var documentCache: [String: DocumentNode] = [:]
    
    private var result: Result<DocumentNode, JudoError>
    private var componentName: ComponentName?
    private var properties: [PropertyName: Any] = [:]
    private var actionHandlers: [ActionName: ActionHandler] = [:]
    
    public init(_ fileName: String, bundle: Bundle = .main) {
        let name = (fileName as NSString).deletingPathExtension
        
        guard let path = bundle.path(forResource: name, ofType: "judo") else {
            self.init(error: .fileNotFound(path: fileName))
            return
        }
        
        if let document = JudoView.documentCache[path] {
            self.init(document: document)
            return
        }
        
        guard let data = FileManager.default.contents(atPath: path) else {
            self.init(error: .fileNotFound(path: path))
            return
        }
        
        do {
            let document = try DocumentNode.read(from: data)
            JudoView.documentCache[path] = document
            self.init(document: document)
        } catch {
            self.init(error: .dataCorrupted)
        }
    }
    
    public init(data: Data) {
        do {
            let document = try DocumentNode.read(from: data)
            self.init(document: document)
        } catch {
            self.init(error: .dataCorrupted)
        }
    }
    
    public init(document: DocumentNode) {
        self.result = .success(document)
    }
    
    private init(error: JudoError) {
        self.result = .failure(error)
    }
    
    public var body: some SwiftUI.View {
        switch result {
        case .success(let document):
            if let startPoint = document.startPoint(preferring: componentName) {
                switch startPoint {
                case .artboard(let artboard):
                    ArtboardView(
                        artboard: artboard,
                        userBindings: userBindings,
                        userViews: userViews
                    )
                    .id(userBindings.mapValues(\.value))
                    .environment(\.document, document)
                    .environment(\.assetManager, AssetManager(assets: document.assets))
                    .environment(\.actionHandlers, actionHandlers)

                case .component(let component):
                    MainComponentView(
                        component: component,
                        userBindings: userBindings,
                        userViews: userViews
                    )
                    .id(userBindings.mapValues(\.value))
                    .environment(\.document, document)
                    .environment(\.assetManager, AssetManager(assets: document.assets))
                    .environment(\.actionHandlers, actionHandlers)
                }
            } else {
                JudoErrorView(.emptyFile)
            }
        case .failure(let error):
            JudoErrorView(error)
        }
    }

    private var userViews: [String: any View] {
        var result: [String: any View] = [:]
        for (key, anyValue) in properties {
            switch anyValue {
            case let value as any View:
                result[key.rawValue] = value
            default:
                break
            }
        }
        return result
    }

    /// Convert user provided properties (Any), to corresponding ComponentBinding
    private var userBindings: [String: ComponentBinding] {
        var result: [String: ComponentBinding] = [:]

        for (key, anyValue) in properties {
            switch anyValue {
            case let value as IntegerLiteralType:
                result[key.rawValue] = ComponentBinding(.number(Double(value)))
            case let bindingValue as Binding<Int>:
                let propertyValueBinding = Binding {
                    PropertyValue.number(Double(bindingValue.wrappedValue))
                } set: { newValue in
                    if case .number(let value) = newValue {
                        bindingValue.wrappedValue = Int(value)
                    }
                }
                result[key.rawValue] = ComponentBinding(propertyValueBinding)
            case let value as FloatLiteralType:
                result[key.rawValue] = ComponentBinding(.number(value))
            case let bindingValue as Binding<Double>:
                let propertyValueBinding = Binding {
                    PropertyValue.number(bindingValue.wrappedValue)
                } set: { newValue in
                    if case .number(let value) = newValue {
                        bindingValue.wrappedValue = value
                    }
                }
                result[key.rawValue] = ComponentBinding(propertyValueBinding)
            case let value as BooleanLiteralType:
                result[key.rawValue] = ComponentBinding(.boolean(value))
            case let bindingValue as Binding<Bool>:
                let propertyValueBinding = Binding {
                    PropertyValue.boolean(bindingValue.wrappedValue)
                } set: { newValue in
                    if case .boolean(let value) = newValue {
                        bindingValue.wrappedValue = value
                    }
                }
                result[key.rawValue] = ComponentBinding(propertyValueBinding)
            case let value as StringLiteralType:
                result[key.rawValue] = ComponentBinding(.text(value))
            case let bindingValue as Binding<String>:
                let propertyValueBinding = Binding {
                    PropertyValue.text(bindingValue.wrappedValue)
                } set: { newValue in
                    if case .text(let value) = newValue {
                        bindingValue.wrappedValue = value
                    }
                }
                result[key.rawValue] = ComponentBinding(propertyValueBinding)
            case let value as SwiftUI.Image:
                result[key.rawValue] = ComponentBinding(.image(.inline(image: value)))
            case let value as UIImage:
                let image = SwiftUI.Image(uiImage: value)
                result[key.rawValue] = ComponentBinding(.image(.inline(image: image)))
            case is any View:
                break
            default:
                logger.warning("Invalid value for property \"\(key)\". Property unused.")
                break
            }
        }

        return result
    }

    public func component(_ componentName: ComponentName) -> JudoView {
        var result = self
        result.componentName = componentName
        return result
    }
    
    public func property(_ propertyName: PropertyName, _ value: Any) -> JudoView {
        var result = self
        result.properties[propertyName] = value
        return result
    }
    
    public func properties(_ properties: [PropertyName: Any]) -> JudoView {
        var result = self
        result.properties = properties
        return result
    }
    
    public func action(_ actionName: ActionName, handler: @escaping ActionHandler) -> JudoView {
        var result = self
        result.actionHandlers[actionName] = handler
        return result
    }
    
    // MARK: Deprecations
    
    @available(*, deprecated, message: "use 'init(_:bundle:)' instead")
    public init(_ fileName: String, bundle: Bundle = .main, component componentName: String? = nil, properties: [String: Any] = [:]) {
        self.init(fileName, bundle: bundle)
        
        self.componentName = componentName.map {
            ComponentName($0)
        }
        
        self.properties = properties.reduce(into: [:]) { partialResult, element in
            let key = PropertyName(element.key)
            partialResult[key] = element.value
        }
    }
    
    @available(*, deprecated, renamed: "action(_:handler:)")
    public func on(_ actionName: ActionName, handler: @escaping ActionHandler) -> JudoView {
        return action(actionName, handler: handler)
    }
}
