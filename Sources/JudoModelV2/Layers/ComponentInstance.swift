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

public final class ComponentInstance: Layer, Modifiable, AssetProvider {
    public class override var humanName: String {
        "Component"
    }

    public enum ComponentValue: CustomStringConvertible, Hashable {
        case reference(mainComponent: MainComponent)
        case property(name: String)
        
        public var description: String {
            switch self {
            case .reference(let mainComponent):
                return mainComponent.description
            case .property(let name):
                return name
            }
        }

        public func resolve(properties: MainComponent.Properties) -> MainComponent? {
            switch self {
            case .reference(let mainComponent):
                return mainComponent
            case .property(let name):
                switch properties[name] {
                case .component(let mainComponent):
                    return mainComponent
                default:
                    return nil
                }
            }
        }
    }

    public enum Override {
        public enum Value: Hashable, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral {
            case text(TextValue)
            case number(CGFloat)
            case boolean(Bool)
            case image(ImageValue)
            case component(ComponentValue)

            public init(stringLiteral value: StringLiteralType) {
                self = .text(TextValue(stringLiteral: value))
            }

            public init(floatLiteral value: FloatLiteralType) {
                self = .number(value)
            }

            public init(integerLiteral value: IntegerLiteralType) {
                self = .number(CGFloat(value))
            }

            public init(booleanLiteral value: BooleanLiteralType) {
                self = .boolean(value)
            }
        }
    }
    
    public typealias Overrides = Dictionary<String, Override.Value>
    
    @Published public var value: ComponentValue
    @Published public var overrides = Overrides()

    public init(referencing mainComponent: MainComponent) {
        self.value = .reference(mainComponent: mainComponent)
        super.init()
    }
    
    // We need an initializer with empty arguments to support the `NSCopying`
    // protocol with inheritance. However, the `value` property is required.
    // To get around this, we set the value to reference a temporary dummy
    // `MainComponent. This dummy component doesn't belong to the layer
    // hierarchy so it is imperative to set the `value` property immediately
    // after using this version of the initializer to avoid a crash.
    public required init() {
        value = .reference(mainComponent: .dummyComponent)
        super.init()
    }

    // MARK: AssetProvider

    public var assetNames: [AssetName] {
        var images: Set<ImageValue> = []
        let properties = enclosingComponent?.properties ?? MainComponent.Properties()
        if let mainComponent = value.resolve(properties: properties) {
            let properties = mainComponent.properties
            for (key, value) in properties {
                switch value {
                case .image(let imageReference):
                    if case .image(let overrideImageValue) = overrides[key] {
                        images.insert(overrideImageValue)
                    } else {
                        images.insert(ImageValue.reference(imageReference: imageReference))
                    }
                default:
                    break
                }
            }
        }

        return images.compactMap { imageValue in
            if case .reference(let reference) = imageValue, case .document(let imageName) = reference {
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
        case reference
        case property
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
        value = .reference(mainComponent: .dummyComponent)
        
        try super.init(from: decoder)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Value
        
        let valueContainer = try container.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .value
        )
        
        var allValueKeys = ArraySlice(valueContainer.allKeys)
        guard let onlyValueKey = allValueKeys.popFirst(), allValueKeys.isEmpty else {
            throw DecodingError.typeMismatch(
                ComponentValue.self,
                DecodingError.Context(
                    codingPath: valueContainer.codingPath,
                    debugDescription: "Invalid number of keys found, expected one.",
                    underlyingError: nil
                )
            )
        }
        
        switch onlyValueKey {
        case .reference:
            let nestedContainer = try valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
            let mainComponentID = try nestedContainer.decode(Node.ID.self, forKey: .mainComponentID)

            coordinator.defer { [unowned self] in
                guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                    let context = DecodingError.Context(
                        codingPath: nestedContainer.codingPath,
                        debugDescription: "No component found with ID \(mainComponentID)",
                        underlyingError: nil
                    )
                    
                    throw DecodingError.dataCorrupted(context)
                }
                
                self.value = .reference(mainComponent: mainComponent)
            }
            
        case .property:
            let nestedContainer = try valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
            let name = try nestedContainer.decode(String.self, forKey: .name)
            value = .property(name: name)
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
                let value = try nestedContainer.decode(TextValue.self, forKey: ._0)
                partialResult[key.stringValue] = .text(value)
            case .number:
                let nestedContainer = try container.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .number)
                let value = try nestedContainer.decode(CGFloat.self, forKey: ._0)
                partialResult[key.stringValue] = .number(value)
            case .boolean:
                let nestedContainer = try container.nestedContainer(keyedBy: BooleanCodingKeys.self, forKey: .boolean)
                let value = try nestedContainer.decode(Bool.self, forKey: ._0)
                partialResult[key.stringValue] = .boolean(value)
            case .image:
                let nestedContainer = try container.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)
                let value = try nestedContainer.decode(ImageValue.self, forKey: ._0)
                partialResult[key.stringValue] = .image(value)
            case .component:
                let nestedContainer = try container.nestedContainer(keyedBy: ComponentCodingKeys.self, forKey: .component)
                
                let container = try nestedContainer.nestedContainer(
                    keyedBy: ValueCodingKeys.self,
                    forKey: ._0
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
                case .reference:
                    let nestedContainer = try container.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
                    let mainComponentID = try nestedContainer.decode(Node.ID.self, forKey: .mainComponentID)

                    coordinator.defer { [unowned self] in
                        guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                            fatalError()
                        }

                        let value = ComponentValue.reference(mainComponent: mainComponent)
                        self.overrides[key.stringValue] = .component(value)
                    }
                case .property:
                    let nestedContainer = try container.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
                    let name = try nestedContainer.decode(String.self, forKey: .name)
                    let value = ComponentValue.property(name: name)
                    self.overrides[key.stringValue] = .component(value)
                }
            }
        }
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Value
        
        var valueContainer = container.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: .value)
        
        switch value {
        case .reference(let mainComponent):
            var nestedContainer = valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
            try nestedContainer.encode(mainComponent.id, forKey: ReferenceCodingKeys.mainComponentID)
        case .property(let name):
            var nestedContainer = valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
            try nestedContainer.encode(name, forKey: PropertyCodingKeys.name)
        }
        
        // Overrides
        
        var overridesContainer = container.nestedContainer(keyedBy: OverridesCodingKeys.self, forKey: .overrides)
        
        for (key, value) in overrides {
            let key = OverridesCodingKeys(stringValue: key)!
            var container = overridesContainer.nestedContainer(keyedBy: OverrideCodingKeys.self, forKey: key)// encoder.container(keyedBy: ComponentInstance.OverrideValue.CodingKeys.self)
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
                var nestedContainer = container.nestedContainer(keyedBy: ComponentCodingKeys.self, forKey: .component)
                                
                var valueContainer = nestedContainer.nestedContainer(keyedBy: ValueCodingKeys.self, forKey: ._0)
                
                switch value {
                case .reference(let mainComponent):
                    var nestedContainer = valueContainer.nestedContainer(keyedBy: ReferenceCodingKeys.self, forKey: .reference)
                    try nestedContainer.encode(mainComponent.id, forKey: ReferenceCodingKeys.mainComponentID)
                case .property(let name):
                    var nestedContainer = valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
                    try nestedContainer.encode(name, forKey: PropertyCodingKeys.name)
                }
            }
        }
        
        try super.encode(to: encoder)
    }
}

fileprivate extension MainComponent {
    static let dummyComponent = MainComponent()
}
