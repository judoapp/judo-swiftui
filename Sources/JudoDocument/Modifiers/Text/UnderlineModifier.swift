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

public struct UnderlineModifier: Modifier {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var color: ColorReference
    public var isActive: Variable<Bool>
    public var pattern: TextLineStylePattern


    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, color: ColorReference, isActive: Variable<Bool>, pattern: TextLineStylePattern) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.color = color
        self.isActive = isActive
        self.pattern = pattern
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
        case color
        case isActive
        case pattern
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)
        isLocked = try container.decode(Bool.self, forKey: .isLocked)
        color = try container.decode(ColorReference.self, forKey: .color)
        isActive = try container.decode(Variable<Bool>.self, forKey: .isActive)
        pattern = try container.decode(TextLineStylePattern.self, forKey: .pattern)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(color, forKey: .color)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(pattern, forKey: .pattern)
    }
}
