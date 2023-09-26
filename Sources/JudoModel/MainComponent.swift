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

/// Component element
public final class MainComponent: Element {
    public class override var humanName: String {
        "Component"
    }
    
    public typealias Properties = OrderedDictionary<String, Property.Value>

    @Published public var properties = Properties()
    @Published public var showInMenu: Bool = true
    @Published public var canvasPreview = CanvasPreview(frame: .device)

    public required init() {
        super.init()
    }

    // MARK: Hierarchy

    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is Layer.Type:
            return true
        default:
            return false
        }
    }

    // MARK: Property Resolution
    
    public func resolveProperties(properties: MainComponent.Properties, overrides: ComponentInstance.Overrides, data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) -> MainComponent.Properties {
        var result = self.properties
        self.properties.forEach { (key, value) in
            switch (value, overrides[key]) {
            case (.text(let defaultValue), .text(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    data: data,
                    fetchedImage: fetchedImage
                )
                
                result[key] = .text(resolvedValue ?? defaultValue)
            case (.number(let defaultValue), .number(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    data: data,
                    fetchedImage: fetchedImage
                )
                
                result[key] = .number(resolvedValue ?? defaultValue)
            case (.boolean(let defaultValue), .boolean(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    data: data,
                    fetchedImage: fetchedImage
                )

                result[key] = .boolean(resolvedValue ?? defaultValue)
            case (.image(let defaultValue), .image(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    data: data,
                    fetchedImage: fetchedImage
                )

                result[key] = .image(resolvedValue ?? defaultValue)
            case (.component(let defaultValue), .component(let value)):
                let resolvedValue = value.resolve(
                    properties: properties,
                    data: data,
                    fetchedImage: fetchedImage
                )
                
                result[key] = .component(resolvedValue ?? defaultValue)
            default:
                break
            }
        }
        
        return result
    }
    
    // MARK: Assets

    public override func strings() -> [String] {
        let strings = super.strings()

        let result: [String] = properties.values
            .compactMap {
                guard case let .text(text) = $0 else { return nil }
                return text
            }
        return strings + result
    }
    
    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let component = super.copy(with: zone) as! MainComponent
        component.properties = properties
        component.showInMenu = showInMenu
        component.canvasPreview = canvasPreview
        return component
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case properties
        case showInMenu
        case canvasPreview
        
        // Beta 1-4
        case artboardSize
    }
    
    private struct PropertiesCodingKeys: CodingKey {
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
    
    private enum PropertyValueCodingKeys: String, CodingKey {
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

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        canvasPreview = try container.decode(CanvasPreview.self, forKey: .canvasPreview)
        showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
        
        // Properties
        //
        // Manually decode `properties` so we can reference existing
        // `MainComponent` instances by ID lookup, instead of decoding a copy.

        func decodeProperty(
            propertyKey: String,
            container: KeyedDecodingContainer<MainComponent.PropertyValueCodingKeys>,
            into properties: inout Properties
        ) throws {
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    Property.Value.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one.",
                        underlyingError: nil
                    )
                )
            }

            switch onlyKey {
            case .text:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: TextCodingKeys.self,
                    forKey: .text
                )

                let text = try nestedContainer.decode(String.self, forKey: ._0)
                properties[propertyKey] = .text(text)

            case .number:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: NumberCodingKeys.self, forKey: .number
                )

                let number = try nestedContainer.decode(CGFloat.self, forKey: ._0)
                properties[propertyKey] = .number(number)

            case .boolean:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: BooleanCodingKeys.self,
                    forKey: .boolean
                )

                let boolean = try nestedContainer.decode(Bool.self, forKey: ._0)
                properties[propertyKey] = .boolean(boolean)

            case .image:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: ImageCodingKeys.self,
                    forKey: .image
                )

                let imageName = try nestedContainer.decode(ImageReference.self, forKey: ._0)
                properties[propertyKey] = .image(imageName)

            case .component:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: ComponentCodingKeys.self,
                    forKey: .component
                )

                // Decode ID
                let mainComponentID = try nestedContainer.decode(
                    Node.ID.self,
                    forKey: ._0
                )

                // Create a temporary place holder for the MainComponent that will be overwritten by the defer
                // this is to ensure that order is maintained.
                properties[propertyKey] = .component(.dummyComponent)

                // Lookup by ID
                coordinator.defer { [unowned self] in
                    guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                        let context = DecodingError.Context(
                            codingPath: nestedContainer.codingPath,
                            debugDescription: "No component found with ID \(mainComponentID)",
                            underlyingError: nil
                        )

                        throw DecodingError.dataCorrupted(context)
                    }

                    self.properties[propertyKey] = .component(mainComponent)
                    return true
                }
            }
        }

        do {
            var propertiesContainer = try container.nestedUnkeyedContainer(forKey: .properties)
            while !propertiesContainer.isAtEnd {

                let key = try propertiesContainer.decode(String.self)

                if properties[key] != nil {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: propertiesContainer.codingPath,
                            debugDescription: "Duplicate key: \(key), at offset \(propertiesContainer.currentIndex - 1)"
                        )
                    )
                }

                let nestedContainer = try propertiesContainer.nestedContainer(keyedBy: PropertyValueCodingKeys.self)
                try decodeProperty(propertyKey: key, container: nestedContainer, into: &properties)
            }
        } catch {
            // Beta 1-5
            let propertiesContainer = try container.nestedContainer(
                keyedBy: PropertiesCodingKeys.self,
                forKey: .properties
            )

            properties = try propertiesContainer.allKeys.reduce(into: [:]) { partialResult, key in
                let container = try propertiesContainer.nestedContainer(
                    keyedBy: PropertyValueCodingKeys.self,
                    forKey: key
                )
                try decodeProperty(propertyKey: key.stringValue, container: container, into: &partialResult)
            }
        }
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showInMenu, forKey: .showInMenu)
        try container.encode(canvasPreview, forKey: .canvasPreview)
        
        // Properties
        //
        // Manually encode `properties` so we can encode `MainComponent` IDs
        // instead of the entire object
        // Copy the how an OrderedDictionary encodes so that order can be maintained.

        var propertiesContainer = container.nestedUnkeyedContainer(forKey: .properties)

        for element in properties {

            try propertiesContainer.encode(element.key)

            switch element.value {
            case .text(let text):
                let key = PropertiesCodingKeys(stringValue: PropertyValueCodingKeys.text.rawValue)!
                var nestedContainer = propertiesContainer.nestedContainer(keyedBy: PropertiesCodingKeys.self)
                var object = nestedContainer.nestedContainer(keyedBy: TextCodingKeys.self, forKey: key)
                try object.encode(text, forKey: ._0)

            case .number(let number):
                let key = PropertiesCodingKeys(stringValue: PropertyValueCodingKeys.number.rawValue)!
                var nestedContainer = propertiesContainer.nestedContainer(keyedBy: PropertiesCodingKeys.self)
                var object = nestedContainer.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: key)
                try object.encode(number, forKey: ._0)

            case .boolean(let boolean):
                let key = PropertiesCodingKeys(stringValue: PropertyValueCodingKeys.boolean.rawValue)!
                var nestedContainer = propertiesContainer.nestedContainer(keyedBy: PropertiesCodingKeys.self)
                var object = nestedContainer.nestedContainer(keyedBy: BooleanCodingKeys.self, forKey: key)
                try object.encode(boolean, forKey: ._0)

            case .image(let imageName):
                let key = PropertiesCodingKeys(stringValue: PropertyValueCodingKeys.image.rawValue)!
                var nestedContainer = propertiesContainer.nestedContainer(keyedBy: PropertiesCodingKeys.self)
                var object = nestedContainer.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: key)
                try object.encode(imageName, forKey: ._0)

            case .component(let component):

                let key = PropertiesCodingKeys(stringValue: PropertyValueCodingKeys.component.rawValue)!
                var nestedContainer = propertiesContainer.nestedContainer(keyedBy: PropertiesCodingKeys.self)
                var object = nestedContainer.nestedContainer(keyedBy: ComponentCodingKeys.self, forKey: key)

                // Encode ID
                try object.encode(component.id, forKey: ._0)
            }
        }
        
        try super.encode(to: encoder)
    }
}

extension MainComponent {
    static let dummyComponent = MainComponent(name: "Dummy")
}
