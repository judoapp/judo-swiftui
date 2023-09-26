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

import Foundation
import OrderedCollections
import SwiftUI

public final class ComponentInstance: Layer, Modifiable, AssetProvider {
    public class override var humanName: String {
        "Component"
    }

    public enum Override {
        public enum Value: Hashable, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral {
            case text(Variable<String>)
            case number(Variable<Double>)
            case boolean(Variable<Bool>)
            case image(Variable<ImageReference>)
            case component(Variable<MainComponent>)

            public init(stringLiteral value: StringLiteralType) {
                self = .text(Variable<String>(stringLiteral: value))
            }

            public init(floatLiteral value: FloatLiteralType) {
                self = .number(Variable(floatLiteral: value))
            }

            public init(integerLiteral value: IntegerLiteralType) {
                self = .number(Variable(floatLiteral: Double(value)))
            }

            public init(booleanLiteral value: BooleanLiteralType) {
                self = .boolean(Variable(value))
            }
        }
    }
    
    public typealias Overrides = Dictionary<MainComponent.Properties.Key, Override.Value>
    
    @Published public var value: Variable<MainComponent>
    @Published public var overrides = Overrides()

    public init(referencing mainComponent: MainComponent) {
        self.value = Variable(mainComponent)
        super.init()
    }
    
    // We need an initializer with empty arguments to support the `NSCopying`
    // protocol with inheritance. However, the `value` property is required.
    // To get around this, we set the value to reference a temporary dummy
    // `MainComponent. This dummy component doesn't belong to the layer
    // hierarchy so it is imperative to set the `value` property immediately
    // after using this version of the initializer to avoid a crash.
    public required init() {
        value = Variable(.dummyComponent)
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.value, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        
        updateOverrides(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    private func updateOverrides(
        properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        for (key, value) in overrides {
            switch value {
            case .text(let textValue):
                if case .property(let propertyName) = textValue.binding {
                    updateTextNumberOverride(
                        keyPath: \.overrides[key],
                        propertyName: propertyName,
                        properties: properties,
                        unbind: unbind,
                        undoManager: undoManager
                    )
                }
            case .number(let numberValue):
                if case .property(let propertyName) = numberValue.binding {
                    updateTextNumberOverride(
                        keyPath: \.overrides[key],
                        propertyName: propertyName,
                        properties: properties,
                        unbind: unbind,
                        undoManager: undoManager
                    )
                }
            case .boolean(let booleanValue):
                if case .property(let propertyName) = booleanValue.binding {
                    updateBooleanOverride(
                        keyPath: \.overrides[key],
                        propertyName: propertyName,
                        properties: properties,
                        unbind: unbind,
                        undoManager: undoManager
                    )
                }
            case .image(let imageValue):
                if case .property(let propertyName) = imageValue.binding {
                    updateImageOverride(
                        keyPath: \.overrides[key],
                        propertyName: propertyName,
                        properties: properties,
                        unbind: unbind,
                        undoManager: undoManager
                    )
                }
            case .component(let componentValue):
                if case .property(let propertyName) = componentValue.binding {
                    updateComponentOverride(
                        keyPath: \.overrides[key],
                        propertyName: propertyName,
                        properties: properties,
                        unbind: unbind,
                        undoManager: undoManager
                    )
                }
            }
        }
    }
    
    private func updateTextNumberOverride(
        keyPath: ReferenceWritableKeyPath<ComponentInstance, ComponentInstance.Override.Value?>,
        propertyName: String,
        properties: MainComponent.Properties,
        unbind: Bool,
        undoManager: UndoManager?
    ) {
        switch properties[propertyName] {
        case .text(let stringValue):
            var newValue = Variable(stringValue, binding: .property(name: propertyName))
            
            if unbind {
                newValue.unbind()
            }

            set(keyPath, to: .text(newValue), undoManager: undoManager)
        case .number(let floatValue):
            let stringValue: String
            if #available(macOS 12.0, iOS 15.0, *) {
                stringValue = floatValue.formatted()
            } else {
                stringValue = floatValue.description
            }
            
            var newValue = Variable(stringValue, binding: .property(name: propertyName))
            
            if unbind {
                newValue.unbind()
            }

            set(keyPath, to: .text(newValue), undoManager: undoManager)
        default:
            break
        }
    }

    private func updateBooleanOverride(
        keyPath: ReferenceWritableKeyPath<ComponentInstance, ComponentInstance.Override.Value?>,
        propertyName: String,
        properties: MainComponent.Properties,
        unbind: Bool,
        undoManager: UndoManager?
    ) {
        switch properties[propertyName] {
        case .boolean(let boolValue):
            var newValue = Variable(boolValue, binding: .property(name: propertyName))
            
            if unbind {
                newValue.unbind()
            }
            
            set(keyPath, to: .boolean(newValue), undoManager: undoManager)
        default:
            break
        }
    }
    
    private func updateImageOverride(
        keyPath: ReferenceWritableKeyPath<ComponentInstance, ComponentInstance.Override.Value?>,
        propertyName: String,
        properties: MainComponent.Properties,
        unbind: Bool,
        undoManager: UndoManager?
    ) {
        switch properties[propertyName] {
        case .image(let imageReference):
            var newValue = Variable<ImageReference>(imageReference, binding: .property(name: propertyName))
            
            if unbind {
                newValue.unbind()
            }

            set(keyPath, to: .image(newValue), undoManager: undoManager)
        default:
            break
        }
    }
    
    private func updateComponentOverride(
        keyPath: ReferenceWritableKeyPath<ComponentInstance, ComponentInstance.Override.Value?>,
        propertyName: String,
        properties: MainComponent.Properties,
        unbind: Bool,
        undoManager: UndoManager?
    ) {
        switch properties[propertyName] {
        case .component(let mainComponent):
            var newValue = Variable(mainComponent, binding: .property(name: propertyName))
            
            if unbind {
                newValue.unbind()
            }

            set(keyPath, to: .component(newValue), undoManager: undoManager)
        default:
            break
        }
    }
    
    // MARK: AssetProvider

    public var assetNames: [AssetName] {
        var images: Set<Variable<ImageReference>> = []
        let properties = enclosingComponent?.properties ?? MainComponent.Properties()
        if let mainComponent = value.resolve(properties: properties) {
            let properties = mainComponent.properties
            for (key, value) in properties {
                switch value {
                case .image(let imageReference):
                    if case .image(let overrideImageValue) = overrides[key] {
                        images.insert(overrideImageValue)
                    } else {
                        images.insert(Variable(imageReference))
                    }
                default:
                    break
                }
            }
        }

        return images.compactMap { imageVariable in
            if case .document(let imageName) = imageVariable.constant {
                return imageName
            }
            return nil
        }
    }

    // MARK: Description
    
    public override var description: String {
        if let name {
            return name
        }
        
        return value.description
    }

    // MARK: Assets

    override public func strings() -> [String] {
        let strings = super.strings()

        let result: [String] = overrides.values
            .compactMap { value in
                guard case .text(let textValue) = value else {
                    return nil
                }

                return textValue.constant
            }

        return strings + result
    }
    
    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let componentInstance = super.copy(with: zone) as! ComponentInstance
        componentInstance.value = value
        componentInstance.overrides = overrides
        return componentInstance
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case value
        case overrides
    }
    
    private enum ValueCodingKeys: CodingKey {
        case reference // constant
        case property  // binding
    }
    
    private enum ReferenceCodingKeys: CodingKey {
        case mainComponentID
    }
    
    private enum PropertyCodingKeys: CodingKey {
        case name
    }
    
    private struct OverridesCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int? {
            nil
        }
        
        init?(intValue: Int) {
            fatalError()
        }
    }
    
    private enum OverrideCodingKeys: CodingKey {
        case text
        case number
        case boolean
        case image
        case component
    }
    
    private enum TextCodingKeys: CodingKey {
        case _0
    }
    
    private enum NumberCodingKeys: CodingKey {
        case _0
    }
    
    private enum BooleanCodingKeys: CodingKey {
        case _0
    }
    
    private enum ImageCodingKeys: CodingKey {
        case _0
    }
    
    private enum ComponentCodingKeys: CodingKey {
        case _0
    }
    
    required public init(from decoder: Decoder) throws {
        // The value property is not optional, however we can't set it until
        // afer the `DecodingCoordinator` has finished decoding all the
        // `MainComponent`s so we can wire up object references. To get around
        // this we temporarily set the value property to reference a dummy
        // component. This will get corrected further down in the decode logic.
        value = Variable(.dummyComponent)
        
        try super.init(from: decoder)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Value
        let valueContainer = try container.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .value
        )

        guard !valueContainer.allKeys.isEmpty else {
            let context = DecodingError.Context(
                codingPath: valueContainer.codingPath,
                debugDescription: "Invalid number of keys found, expected at least one.",
                underlyingError: nil
            )

            throw DecodingError.dataCorrupted(context)
        }

        if valueContainer.contains(.reference) {
            let referenceContainer = try valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
            let mainComponentID = try referenceContainer.decode(Node.ID.self, forKey: .mainComponentID)

            coordinator.defer { [unowned self] in
                guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                    let context = DecodingError.Context(
                        codingPath: referenceContainer.codingPath,
                        debugDescription: "No component found with ID \(mainComponentID)",
                        underlyingError: nil
                    )

                    throw DecodingError.dataCorrupted(context)
                }

                self.value = Variable(mainComponent, binding: self.value.binding)
                return true
            }
        }

        if valueContainer.contains(.property) {
            let propertyContainer = try valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
            let propertyName = try propertyContainer.decode(String.self, forKey: .name)
            value.bind(to: .property(name: propertyName))

            coordinator.defer { [unowned self] in
                // Resolve .dummyComponent from the property binding
                if self.value.constant == .dummyComponent, let resolvedMainComponent = self.value.resolve(properties: self.enclosingComponent?.properties ?? [:]) {
                    if resolvedMainComponent == .dummyComponent {
                        // enclosingComponent.properties are not resolved yet, resulting in resolution to unresolved value
                        return false
                    }
                    self.value = Variable(resolvedMainComponent, binding: self.value.binding)
                }

                return true
            }
        }

        // Overrides
        
        let overridesContainer = try container.nestedContainer(keyedBy: OverridesCodingKeys.self, forKey: .overrides)
        overrides = try overridesContainer.allKeys.reduce(into: [:]) { partialResult, key in
            let container = try overridesContainer.nestedContainer(
                keyedBy: OverrideCodingKeys.self,
                forKey: key
            )
            
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    ComponentInstance.Override.Value.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one.",
                        underlyingError: nil
                    )
                )
            }
            
            switch onlyKey {
            case .text:
                let nestedContainer = try container.nestedContainer(keyedBy: TextCodingKeys.self, forKey: .text)
                switch coordinator.documentVersion {
                case ..<17:
                    let value = try Variable(nestedContainer.decode(LegacyTextValue.self, forKey: ._0))
                    partialResult[key.stringValue] = .text(value)
                default:
                    let value = try nestedContainer.decode(Variable<String>.self, forKey: ._0)
                    partialResult[key.stringValue] = .text(value)
                }
            case .number:
                let nestedContainer = try container.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .number)
                
                switch coordinator.documentVersion {
                case ..<14:
                    let floatLiteral = try nestedContainer.decode(CGFloat.self, forKey: ._0)
                    let value = LegacyNumberValue(floatLiteral)
                    partialResult[key.stringValue] = .number(Variable(value))
                case ..<17:
                    let value = try nestedContainer.decode(LegacyNumberValue.self, forKey: ._0)
                    partialResult[key.stringValue] = .number(Variable(value))
                default:
                    let value = try nestedContainer.decode(Variable<Double>.self, forKey: ._0)
                    partialResult[key.stringValue] = .number(value)
                }
            case .boolean:
                let nestedContainer = try container.nestedContainer(keyedBy: BooleanCodingKeys.self, forKey: .boolean)
                
                switch coordinator.documentVersion {
                case ..<14:
                    let booleanLiteral = try nestedContainer.decode(Bool.self, forKey: ._0)
                    let value = Variable(booleanLiteral)
                    partialResult[key.stringValue] = .boolean(value)
                case ..<17:
                    let value = try nestedContainer.decode(LegacyBooleanValue.self, forKey: ._0)
                    partialResult[key.stringValue] = .boolean(Variable(value))
                default:
                    let value = try nestedContainer.decode(Variable<Bool>.self, forKey: ._0)
                    partialResult[key.stringValue] = .boolean(value)
                }
            case .image:
                let nestedContainer = try container.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)

                switch coordinator.documentVersion {
                case ..<17:
                    let value = try Variable(nestedContainer.decode(LegacyImageValue.self, forKey: ._0))
                    partialResult[key.stringValue] = .image(value)
                default:
                    let value = try nestedContainer.decode(Variable<ImageReference>.self, forKey: ._0)
                    partialResult[key.stringValue] = .image(value)
                }
            case .component:
                let nestedContainer = try container.nestedContainer(keyedBy: ComponentCodingKeys.self, forKey: .component)
                let valueContainer = try nestedContainer.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: ._0)

                guard !valueContainer.allKeys.isEmpty else {
                    let context = DecodingError.Context(
                        codingPath: valueContainer.codingPath,
                        debugDescription: "Invalid number of keys found, expected at least one.",
                        underlyingError: nil
                    )

                    throw DecodingError.dataCorrupted(context)
                }


                if valueContainer.contains(.reference) {
                    let referenceContainer = try valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
                    let mainComponentID = try referenceContainer.decode(Node.ID.self, forKey: .mainComponentID)

                    coordinator.defer { [unowned self] in
                        guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                            fatalError()
                        }

                        let value = Variable(mainComponent, binding: self.value.binding)
                        self.overrides[key.stringValue] = .component(value)
                        return true
                    }
                }

                if valueContainer.contains(.property) {
                    let propertyContainer = try valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
                    let name = try propertyContainer.decode(String.self, forKey: .name)
                    let value = value.bound(to: .property(name: name))
                    self.overrides[key.stringValue] = .component(value)

                    coordinator.defer { [unowned self] in
                        // Resolve .dummyComponent from the property binding
                        if value.constant == .dummyComponent, let resolvedValue = value.resolve(properties: self.enclosingComponent?.properties ?? [:]) {
                            if resolvedValue == .dummyComponent {
                                // try again
                                return false
                            }
                            self.overrides[key.stringValue] = .component(Variable(resolvedValue, binding: value.binding))
                        }
                        return true
                    }
                }
            }
        }
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Value
        var valueContainer = container.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: .value)

        // constant.id
        var referenceContainer = valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
        try referenceContainer.encode(value.constant.id, forKey: .mainComponentID)

        if case .property(let propertyName) = value.binding {
            var propertyContainer = valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
            try propertyContainer.encode(propertyName, forKey: .name)
        }

        if case .data = value.binding {
            assertionFailure("Data binding unexpected (unsupported)")
        }
        
        // Overrides
        
        var overridesContainer = container.nestedContainer(keyedBy: OverridesCodingKeys.self, forKey: .overrides)
        
        for (key, value) in overrides {
            let key = OverridesCodingKeys(stringValue: key)!
            var container = overridesContainer.nestedContainer(keyedBy: OverrideCodingKeys.self, forKey: key)
            switch value {
            case .text(let value):
                var nestedContainer = container.nestedContainer(keyedBy: TextCodingKeys.self, forKey: .text)
                try nestedContainer.encode(value, forKey: ._0)
            case .number(let value):
                var nestedContainer = container.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .number)
                try nestedContainer.encode(value, forKey: ._0)
            case .boolean(let value):
                var nestedContainer = container.nestedContainer(keyedBy: BooleanCodingKeys.self, forKey: .boolean)
                try nestedContainer.encode(value, forKey: ._0)
            case .image(let value):
                var nestedContainer = container.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)
                try nestedContainer.encode(value, forKey: ._0)
            case .component(let value):
                var componentContainer = container.nestedContainer(keyedBy: ComponentCodingKeys.self, forKey: .component)
                var valueContainer = componentContainer.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: ._0)

                // constant.id
                var referenceContainer = valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
                try referenceContainer.encode(value.constant.id, forKey: .mainComponentID)

                if case .property(let name) = value.binding {
                    var propertyContainer = valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
                    try propertyContainer.encode(name, forKey: .name)
                }

                if case .data = value.binding {
                    assertionFailure("Data binding unexpected (unsupported)")
                }
            }
        }
        
        try super.encode(to: encoder)
    }
}
