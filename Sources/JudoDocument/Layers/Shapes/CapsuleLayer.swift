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

public struct CapsuleLayer: Shape {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var rasterizationStyle: RasterizationStyle
    public var shapeStyle: ShapeStyle
    public var lineWidth: CGFloat
    public var cornerStyle: RoundedCornerStyle
    
    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, rasterizationStyle: RasterizationStyle, shapeStyle: ShapeStyle, lineWidth: CGFloat, cornerStyle: RoundedCornerStyle) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.rasterizationStyle = rasterizationStyle
        self.shapeStyle = shapeStyle
        self.lineWidth = lineWidth
        self.cornerStyle = cornerStyle
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
        case rasterizationStyle
        case shapeStyle
        case lineWidth
        case cornerStyle
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)
        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        rasterizationStyle = try container.decode(RasterizationStyle.self, forKey: .rasterizationStyle)
        shapeStyle = try container.decode(ShapeStyle.self, forKey: .shapeStyle)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        cornerStyle = try container.decode(RoundedCornerStyle.self, forKey: .cornerStyle)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(rasterizationStyle, forKey: .rasterizationStyle)
        try container.encode(shapeStyle, forKey: .shapeStyle)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(cornerStyle, forKey: .cornerStyle)
    }
}
