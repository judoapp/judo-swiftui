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

public struct AspectRatioModifier: Modifier {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var ratio: Variable<Double>?
    public var contentMode: ContentMode

    public init(id: UUID, name: String?, children: [Node], ratio: Variable<Double>?, contentMode: ContentMode) {
        self.id = id
        self.name = name
        self.children = children
        self.ratio = ratio
        self.contentMode = contentMode
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case ratio
        case contentMode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<15:
            
            if let floatValue = try container.decodeIfPresent(CGFloat.self, forKey: .ratio) {
                ratio = Variable(LegacyNumberValue(floatValue))
            }
        case ..<17:
            
            if let value = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .ratio) {
                ratio = Variable(value)
            }
        default:
            ratio = try container.decodeIfPresent(Variable<Double>.self, forKey: .ratio)
        }

        contentMode = try container.decode(ContentMode.self, forKey: .contentMode)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(ratio, forKey: .ratio)
        try container.encode(contentMode, forKey: .contentMode)
    }
}

