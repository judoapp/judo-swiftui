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

/// The `PaddingModifier` model mirrors the `padding(_:_:)` SwiftUI modifier—it can be used with a set of edges and an optional length, _or_ it can be used by supplying insets for all four edges.
///
/// When it is used with a set of edges, the `length` property determines the amount of padding applied to all of the edges in the set. If the `length` property is `nil` then the SwiftUI default padding amount is used. When the `PaddingModifier` is used by supplying insets for all four edges, a value must be supplied, the default SwiftUI padding can not be used.
///
/// The model is expected to be used in one of the two ways above: either the edges are set (and optionally a lenght value) _or_ all four of the inset edges are set. There is no compile-time check for this but any unexpected configurations of the modifier are handled gracefully in the Inspector Panel and renderers. 
public struct PaddingModifier: Modifier {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var edges: Edges?
    public var length: Variable<Double>?
    public var leadingInset: Variable<Double>?
    public var trailingInset: Variable<Double>?
    public var topInset: Variable<Double>?
    public var bottomInset: Variable<Double>?

    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, edges: Edges?, length: Variable<Double>?, leadingInset: Variable<Double>?, trailingInset: Variable<Double>?, topInset: Variable<Double>?, bottomInset: Variable<Double>?) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.edges = edges
        self.length = length
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.topInset = topInset
        self.bottomInset = bottomInset
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
        case edges
        case length
        case leadingInset
        case trailingInset
        case topInset
        case bottomInset
        
        // ..<16
        case padding
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<16:
            position = .zero
            isLocked = false
            
            let padding = try container.decode(LegacyPadding.self, forKey: .padding)
            leadingInset = Variable(.constant(value: padding.leading))
            trailingInset = Variable(.constant(value: padding.trailing))
            topInset = Variable(.constant(value: padding.top))
            bottomInset = Variable(.constant(value: padding.bottom))
        case ..<17:
            position = .zero
            isLocked = false
            edges = try container.decode(Edges?.self, forKey: .edges)

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .length) {
                length = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .leadingInset) {
                leadingInset = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .trailingInset) {
                trailingInset = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .topInset) {
                topInset = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .bottomInset) {
                bottomInset = Variable(value)
            }
        case ..<18:
            position = .zero
            isLocked = false
            edges = try container.decode(Edges?.self, forKey: .edges)
            length = try container.decode(Variable<Double>?.self, forKey: .length)
            leadingInset = try container.decode(Variable<Double>?.self, forKey: .leadingInset)
            trailingInset = try container.decode(Variable<Double>?.self, forKey: .trailingInset)
            topInset = try container.decode(Variable<Double>?.self, forKey: .topInset)
            bottomInset = try container.decode(Variable<Double>?.self, forKey: .bottomInset)
        default:
            position = try container.decode(CGPoint.self, forKey: .position)
            isLocked = try container.decode(Bool.self, forKey: .isLocked)
            edges = try container.decode(Edges?.self, forKey: .edges)
            length = try container.decode(Variable<Double>?.self, forKey: .length)
            leadingInset = try container.decode(Variable<Double>?.self, forKey: .leadingInset)
            trailingInset = try container.decode(Variable<Double>?.self, forKey: .trailingInset)
            topInset = try container.decode(Variable<Double>?.self, forKey: .topInset)
            bottomInset = try container.decode(Variable<Double>?.self, forKey: .bottomInset)
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
        try container.encode(edges, forKey: .edges)
        try container.encode(length, forKey: .length)
        try container.encode(leadingInset, forKey: .leadingInset)
        try container.encode(trailingInset, forKey: .trailingInset)
        try container.encode(topInset, forKey: .topInset)
        try container.encode(bottomInset, forKey: .bottomInset)
    }
}
