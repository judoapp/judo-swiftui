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

/// Component element
public final class MainComponent: Element {
    public class override var humanName: String {
        "Component"
    }
    
    public enum ArtboardSize: Codable, Hashable {
        public static let defaultLength: CGFloat = 100
        
        case device
        case fixed(width: CGFloat, height: CGFloat)
        case sizeThatFits
    }

    public enum PropertyValue: Codable, Hashable {
        case text(String)
        case number(CGFloat)
        case boolean(Bool)
        case component(MainComponent)
    }
    
    public typealias Properties = OrderedDictionary<String, PropertyValue>

    @Published public var properties = Properties()
    @Published public var artboardSize = ArtboardSize.device
    @Published public var showInMenu: Bool = true

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
    
    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let component = super.copy(with: zone) as! MainComponent
        component.properties = properties
        component.showInMenu = showInMenu
        component.artboardSize = artboardSize
        return component
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case properties
        case showInMenu
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
    
    private enum PropertyValueCodingKeys: CodingKey {
        case text
        case number
        case boolean
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
    
    private enum ComponentCodingKeys: CodingKey {
        case _0
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        artboardSize = try container.decode(ArtboardSize.self, forKey: .artboardSize)
        showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
        
        // Properties
        //
        // Manually decode `properties` so we can reference existing
        // `MainComponent` instances by ID lookup, instead of decoding a copy.
        
        let propertiesContainer = try container.nestedContainer(
            keyedBy: PropertiesCodingKeys.self,
            forKey: .properties
        )
        
        properties = try propertiesContainer.allKeys.reduce(into: [:]) { partialResult, key in
            let container = try propertiesContainer.nestedContainer(
                keyedBy: PropertyValueCodingKeys.self,
                forKey: key
            )
            
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    PropertyValue.self,
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
                partialResult[key.stringValue] = .text(text)
            case .number:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: NumberCodingKeys.self, forKey: .number
                )
                
                let number = try nestedContainer.decode(CGFloat.self, forKey: ._0)
                partialResult[key.stringValue] = .number(number)
            case .boolean:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: BooleanCodingKeys.self,
                    forKey: .boolean
                )
                
                let boolean = try nestedContainer.decode(Bool.self, forKey: ._0)
                partialResult[key.stringValue] = .boolean(boolean)
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

                // Lookup by ID
                coordinator.defer { [unowned self] in
                    guard let mainComponent = coordinator.nodes[mainComponentID] as? MainComponent else {
                        fatalError()
                    }
                    
                    self.properties[key.stringValue] = .component(mainComponent)
                }
            }
        }
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showInMenu, forKey: .showInMenu)
        try container.encode(artboardSize, forKey: .artboardSize)
        
        // Properties
        //
        // Manually encode `properties` so we can encode `MainComponent` IDs
        // instead of the entire object
        
        var propertiesContainer = container.nestedContainer(
            keyedBy: PropertiesCodingKeys.self,
            forKey: .properties
        )
        
        for element in properties {
            let key = PropertiesCodingKeys(stringValue: element.key)!
            var container = propertiesContainer.nestedContainer(
                keyedBy: PropertyValueCodingKeys.self,
                forKey: key
            )
            
            switch element.value {
            case .text(let text):
                var nestedContainer = container.nestedContainer(
                    keyedBy: TextCodingKeys.self,
                    forKey: .text
                )
                
                try nestedContainer.encode(text, forKey: ._0)
            case .number(let number):
                var nestedContainer = container.nestedContainer(
                    keyedBy: NumberCodingKeys.self,
                    forKey: .number
                )
                
                try nestedContainer.encode(number, forKey: ._0)
            case .boolean(let boolean):
                var nestedContainer = container.nestedContainer(
                    keyedBy: BooleanCodingKeys.self,
                    forKey: .boolean
                )
                
                try nestedContainer.encode(boolean, forKey: ._0)
            case .component(let component):
                var nestedContainer = container.nestedContainer(
                    keyedBy: ComponentCodingKeys.self,
                    forKey: .component
                )
                
                // Encode ID
                try nestedContainer.encode(component.id, forKey: ._0)
            }
        }
        
        try super.encode(to: encoder)
    }
}
