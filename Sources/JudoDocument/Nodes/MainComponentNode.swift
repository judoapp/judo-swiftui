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

public struct MainComponentNode: CanvasNode {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var frame: Frame
    public var previewSettings: PreviewSettings
    public var properties: [Property]
    public var showInMenu: Bool
    public var isStartingPoint: Bool

    public init(id: UUID, name: String?, children: [Node], position: CGPoint, frame: Frame, previewSettings: PreviewSettings, properties: [Property], showInMenu: Bool, isStartingPoint: Bool) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.frame = frame
        self.previewSettings = previewSettings
        self.properties = properties
        self.showInMenu = showInMenu
        self.isStartingPoint = isStartingPoint
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case frame
        case previewSettings
        case properties
        case showInMenu
        case isStartingPoint

        // Legacy
        case artboardSize
        case canvasPreview
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        position = try container.decode(CGPoint.self, forKey: .position)

        func wrapChildrenInZStackIfNeeded() throws -> [Node] {
            let children = try container.decodeNodes(forKey: .children)
            guard children.count > 1 else {
                return children
            }

            return [
                ZStackLayer(
                    id: UUID(),
                    name: "ZStack",
                    children: children,
                    position: .zero,
                    frame: Frame(),
                    isLocked: false,
                    alignment: .center
                )
            ]
        }

        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<18:
            let canvasPreview: LegacyCanvasPreview

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
                    canvasPreview = LegacyCanvasPreview(frame: .device)
                case .fixed(let width, let height):
                    canvasPreview = LegacyCanvasPreview(
                        frame: LegacyCanvasPreview.Frame(
                            width: width,
                            height: height,
                            deviceBezels: false
                        )
                    )
                case .sizeThatFits:
                    canvasPreview = LegacyCanvasPreview(frame: .vertical)
                }
            } else {
                canvasPreview = try container.decode(LegacyCanvasPreview.self, forKey: .canvasPreview)
            }

            let legacyUserData = decoder.userInfo[.legacyUserData] as! LegacyUserData
            frame = Frame(canvasPreview: canvasPreview)
            previewSettings = PreviewSettings(canvasPreview: canvasPreview, legacyUserData: legacyUserData)

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
            children = try wrapChildrenInZStackIfNeeded()
            isStartingPoint = false
        case ..<20:
            let canvasPreview = try container.decode(LegacyCanvasPreview.self, forKey: .canvasPreview)
            let legacyUserData = decoder.userInfo[.legacyUserData] as! LegacyUserData
            frame = Frame(canvasPreview: canvasPreview)
            previewSettings = PreviewSettings(canvasPreview: canvasPreview, legacyUserData: legacyUserData)
            let legacyProperties = try container.decode(LegacyProperties.self, forKey: .properties)
            properties = legacyProperties.properties
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            children = try wrapChildrenInZStackIfNeeded()
            isStartingPoint = false
        case ..<21:
            let canvasPreview = try container.decode(LegacyCanvasPreview.self, forKey: .canvasPreview)
            let legacyUserData = decoder.userInfo[.legacyUserData] as! LegacyUserData
            frame = Frame(canvasPreview: canvasPreview)
            previewSettings = PreviewSettings(canvasPreview: canvasPreview, legacyUserData: legacyUserData)
            properties = try container.decode([Property].self, forKey: .properties)
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            children = try wrapChildrenInZStackIfNeeded()
            isStartingPoint = false
        case ..<22:
            frame = try container.decode(Frame.self, forKey: .frame)
            previewSettings = try container.decode(PreviewSettings.self, forKey: .previewSettings)
            properties = try container.decode([Property].self, forKey: .properties)
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            children = try container.decodeNodes(forKey: .children)
            isStartingPoint = false
        default:
            frame = try container.decode(Frame.self, forKey: .frame)
            previewSettings = try container.decode(PreviewSettings.self, forKey: .previewSettings)
            properties = try container.decode([Property].self, forKey: .properties)
            showInMenu = try container.decode(Bool.self, forKey: .showInMenu)
            children = try container.decodeNodes(forKey: .children)
            isStartingPoint = try container.decode(Bool.self, forKey: .isStartingPoint)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(frame, forKey: .frame)
        try container.encode(previewSettings, forKey: .previewSettings)
        try container.encode(properties, forKey: .properties)
        try container.encode(showInMenu, forKey: .showInMenu)
        try container.encode(isStartingPoint, forKey: .isStartingPoint)
    }
}

private extension Frame {
    init(canvasPreview: LegacyCanvasPreview) {
        if canvasPreview.frame.deviceBezels {
            self.init(
                width: nil,
                height: nil
            )
        } else {
            self.init(
                width: canvasPreview.frame.width,
                height: canvasPreview.frame.height
            )
        }
    }
}

private extension PreviewSettings {
    init(canvasPreview: LegacyCanvasPreview, legacyUserData: LegacyUserData) {
        if canvasPreview.frame.deviceBezels {
            self.device = Device(
                model: Device.Model(legacyUserData: legacyUserData),
                orientation: legacyUserData.deviceOrientation
            )
        } else {
            device = nil
        }
        
        self.isDarkModeEnabled = legacyUserData.isDarkModeEnabled
        self.isHighContrastModeEnabled = legacyUserData.isHighContrastModeEnabled
        self.contentSizeCategory = legacyUserData.contentSizeCategory == .large ? nil : legacyUserData.contentSizeCategory
        self.previewLanguage = legacyUserData.previewLanguage   
    }
}

private extension Device.Model {
    init(legacyUserData: LegacyUserData) {
        switch legacyUserData.deviceSize {
        case .small, .medium:
            self = .iPhone14
        case .large:
            self = .iPhone15ProMax
        case .tablet:
            self = .iPadPro11Inch
        }
    }
}
