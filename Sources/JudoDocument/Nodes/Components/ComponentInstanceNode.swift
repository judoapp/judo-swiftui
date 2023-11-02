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

public struct ComponentInstanceNode: Node {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var value: Variable<UUID>
    public var overrides: Overrides

    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, value: Variable<UUID>, overrides: Overrides) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.value = value
        self.overrides = overrides
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
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
        case video
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

    private enum VideoCodingKeys: CodingKey {
        case _0
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)
        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        
        let meta = decoder.userInfo[.meta] as! Meta
        if meta.version >= 18 {
            value = try container.decode(Variable<UUID>.self, forKey: .value)
            overrides = try container.decode(Overrides.self, forKey: .overrides)
            return
        }
        
        let dummyID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
            
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
            let mainComponentID = try referenceContainer.decode(UUID.self, forKey: .mainComponentID)
            value = Variable(mainComponentID)
        } else if valueContainer.contains(.property) {
            let propertyContainer = try valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
            let propertyName = try propertyContainer.decode(String.self, forKey: .name)
            value = Variable(dummyID, binding: .property(name: propertyName))
        } else {
            let context = DecodingError.Context(
                codingPath: valueContainer.codingPath,
                debugDescription: "Invalid keys found, expected .reference or .property",
                underlyingError: nil
            )

            throw DecodingError.dataCorrupted(context)
        }
        
        // Overrides
        
        overrides = [:]
        
        let overridesContainer = try container.nestedContainer(keyedBy: OverridesCodingKeys.self, forKey: .overrides)
        overrides = try overridesContainer.allKeys.reduce(into: [:]) { partialResult, key in
            let container = try overridesContainer.nestedContainer(
                keyedBy: OverrideCodingKeys.self,
                forKey: key
            )
            
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    Override.self,
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
                switch meta.version {
                case ..<17:
                    let value = try Variable(nestedContainer.decode(LegacyTextValue.self, forKey: ._0))
                    partialResult[key.stringValue] = .text(value)
                default:
                    let value = try nestedContainer.decode(Variable<String>.self, forKey: ._0)
                    partialResult[key.stringValue] = .text(value)
                }
            case .video:
                let nestedContainer = try container.nestedContainer(keyedBy: VideoCodingKeys.self, forKey: .video)
                let value = try Variable(nestedContainer.decode(String.self, forKey: ._0))
                partialResult[key.stringValue] = .video(value)
            case .number:
                let nestedContainer = try container.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .number)
                
                switch meta.version {
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
                
                switch meta.version {
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

                switch meta.version {
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
                    let mainComponentID = try referenceContainer.decode(UUID.self, forKey: .mainComponentID)
                    let value = Variable(mainComponentID)
                    partialResult[key.stringValue] = .component(value)
                }

                if valueContainer.contains(.property) {
                    let propertyContainer = try valueContainer.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .property)
                    let name = try propertyContainer.decode(String.self, forKey: .name)
                    let value = Variable(dummyID, binding: .property(name: name))
                    self.overrides[key.stringValue] = .component(value)
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(value, forKey: .value)
        try container.encode(overrides, forKey: .overrides)
    }
}
