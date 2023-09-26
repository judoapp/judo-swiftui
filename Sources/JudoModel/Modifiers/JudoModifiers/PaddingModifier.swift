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
public class PaddingModifier: JudoModifier {
    @Published public var edges: Edges?
    @Published public var length: Variable<Double>?
    
    @Published public var leadingInset: Variable<Double>?
    @Published public var trailingInset: Variable<Double>?
    @Published public var topInset: Variable<Double>?
    @Published public var bottomInset: Variable<Double>?

    public required init() {
        edges = .all
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.length, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.leadingInset, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.trailingInset, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.topInset, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.bottomInset, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! PaddingModifier
        modifier.edges = edges
        modifier.length = length
        modifier.leadingInset = leadingInset
        modifier.trailingInset = trailingInset
        modifier.topInset = topInset
        modifier.bottomInset = bottomInset
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case edges
        case length
        case leadingInset
        case trailingInset
        case topInset
        case bottomInset
        
        // ..<16
        case padding
    }

    public required init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch coordinator.documentVersion {
        case ..<16:
            let padding = try container.decode(LegacyPadding.self, forKey: .padding)
            leadingInset = Variable(.constant(value: padding.leading))
            trailingInset = Variable(.constant(value: padding.trailing))
            topInset = Variable(.constant(value: padding.top))
            bottomInset = Variable(.constant(value: padding.bottom))
        case ..<17:
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
        default:
            edges = try container.decode(Edges?.self, forKey: .edges)
            length = try container.decode(Variable<Double>?.self, forKey: .length)
            leadingInset = try container.decode(Variable<Double>?.self, forKey: .leadingInset)
            trailingInset = try container.decode(Variable<Double>?.self, forKey: .trailingInset)
            topInset = try container.decode(Variable<Double>?.self, forKey: .topInset)
            bottomInset = try container.decode(Variable<Double>?.self, forKey: .bottomInset)
        }
        
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(edges, forKey: .edges)
        try container.encode(length, forKey: .length)
        try container.encode(leadingInset, forKey: .leadingInset)
        try container.encode(trailingInset, forKey: .trailingInset)
        try container.encode(topInset, forKey: .topInset)
        try container.encode(bottomInset, forKey: .bottomInset)
        try super.encode(to: encoder)
    }
}
