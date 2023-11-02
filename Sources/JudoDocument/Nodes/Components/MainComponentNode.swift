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
import SwiftUI

public struct MainComponentNode: Node {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var properties: Properties
    public var showInMenu: Bool
    public var canvasPreview: CanvasPreview
    
    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, properties: Properties, showInMenu: Bool, canvasPreview: CanvasPreview) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.properties = properties
        self.showInMenu = showInMenu
        self.canvasPreview = canvasPreview
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
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
        
        let meta = decoder.userInfo[.meta] as! Meta
        if meta.version >= 18 {
            isLocked = try container.decode(Bool.self, forKey: .isLocked)
            properties = try container.decode(Properties.self, forKey: .properties)
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            canvasPreview = try container.decode(CanvasPreview.self, forKey: .canvasPreview)
            return
        }
        
        isLocked = false
        properties = [:]

        func decodeProperty(
            propertyKey: String,
            container: KeyedDecodingContainer<MainComponentNode.PropertyValueCodingKeys>,
            into properties: inout Properties
        ) throws {
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    Property.self,
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

                let mainComponentID = try nestedContainer.decode(
                    UUID.self,
                    forKey: ._0
                )

                properties[propertyKey] = .component(mainComponentID)

            case .video:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: VideoCodingKeys.self,
                    forKey: .video
                )

                let video = try nestedContainer.decode(String.self, forKey: ._0)
                properties[propertyKey] = .video(video)
            }
        }
        
        showInMenu = try container.decode(Bool.self, forKey: .showInMenu)

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
        
        // Beta 1-4
        if container.contains(.artboardSize) {
            enum ArtboardSize: Decodable {
                case device
                case fixed(width: CGFloat, height: CGFloat)
                case sizeThatFits
            }
            
            let artboardSize = try container.decode(ArtboardSize.self, forKey: .artboardSize)
            
            switch artboardSize {
            case .device:
                canvasPreview = CanvasPreview(frame: .device, bars: [])
            case .fixed(let width, let height):
                canvasPreview = CanvasPreview(
                    frame: CanvasPreview.Frame(
                        width: width,
                        height: height,
                        deviceBezels: false
                    ),
                    bars: []
                )
            case .sizeThatFits:
                canvasPreview = CanvasPreview(frame: .vertical, bars: [])
            }
        } else {
            canvasPreview = try container.decode(CanvasPreview.self, forKey: .canvasPreview)
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
        try container.encode(properties, forKey: .properties)
        try container.encode(showInMenu, forKey: .showInMenu)
        try container.encode(canvasPreview, forKey: .canvasPreview)
    }
}
