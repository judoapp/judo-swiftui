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
    public var properties: [Property]
    public var showInMenu: Bool
    public var canvasPreview: CanvasPreview
    
    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, properties: [Property], showInMenu: Bool, canvasPreview: CanvasPreview) {
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
        
        // Legacy
        case artboardSize
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)
        
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<18:
            isLocked = false
            
            var legacyProperties = LegacyProperties()
            
            do {
                var propertiesContainer = try container.nestedUnkeyedContainer(forKey: .properties)
                while !propertiesContainer.isAtEnd {
                    let key = try propertiesContainer.decode(String.self)
                    let value = try propertiesContainer.decode(LegacyProperty.self)
                    legacyProperties[key] = value
                }
            } catch {
                // Beta 1-5
                struct PropertiesCodingKeys: CodingKey {
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
                
                let propertiesContainer = try container.nestedContainer(
                    keyedBy: PropertiesCodingKeys.self,
                    forKey: .properties
                )

                for key in propertiesContainer.allKeys {
                    let value = try propertiesContainer.decode(LegacyProperty.self, forKey: key)
                    legacyProperties[key.stringValue] = value
                }
            }
            
            properties = legacyProperties.properties
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            
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
        case ..<20:
            isLocked = try container.decode(Bool.self, forKey: .isLocked)
            let legacyProperties = try container.decode(LegacyProperties.self, forKey: .properties)
            properties = legacyProperties.properties
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            canvasPreview = try container.decode(CanvasPreview.self, forKey: .canvasPreview)
        default:
            isLocked = try container.decode(Bool.self, forKey: .isLocked)
            properties = try container.decode([Property].self, forKey: .properties)
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
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
