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

public struct ClipShapeModifier: Modifier {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var shape: Shape
    public var isEvenOddRule: Variable<Bool>
    public var isAntialiased: Variable<Bool>

    public init(id: UUID, name: String?, children: [Node], shape: Shape, isEvenOddRule: Variable<Bool>, isAntialiased: Variable<Bool>) {
        self.id = id
        self.name = name
        self.children = children
        self.shape = shape
        self.isEvenOddRule = isEvenOddRule
        self.isAntialiased = isAntialiased
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case shape
        case evenOddRule
        case antialiased
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)

        if let shape = try container.decodeNode(for: .shape) as? Shape {
            self.shape = shape
        } else {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid shape"
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        isEvenOddRule = try container.decode(Variable<Bool>.self, forKey: .evenOddRule)
        isAntialiased = try container.decode(Variable<Bool>.self, forKey: .antialiased)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(shape, forKey: .shape)
        try container.encode(isEvenOddRule, forKey: .evenOddRule)
        try container.encode(isAntialiased, forKey: .antialiased)
    }
}
