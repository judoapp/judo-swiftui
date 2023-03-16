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

public final class Conditional: Layer {
    public var conditions = [Condition]() { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    // MARK: Hierarchy

    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild(ofType type: Node.Type) -> Bool {
        switch type {
        case is Rectangle.Type:
            return true
        case is Text.Type:
            return true
        case is Image.Type:
            return true
        case is Icon.Type:
            return true
        case is Video.Type:
            return true
        case is Audio.Type:
            return true
        case is HStack.Type:
            return true
        case is VStack.Type:
            return true
        case is ZStack.Type:
            return true
        case is ScrollContainer.Type:
            return true
        case is DataSource.Type:
            return true
        case is CollectionNode.Type:
            return true
        case is Conditional.Type:
            return true
        case is Carousel.Type:
            return true
        case is PageControl.Type:
            return true
        case is WebViewNode.Type:
            return true
        default:
            return false
        }
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let conditional = super.copy(with: zone) as! Conditional
        conditional.conditions = conditions
        return conditional
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case conditions
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conditions = try container.decode([Condition].self, forKey: .conditions)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(conditions, forKey: .conditions)
        try super.encode(to: encoder)
    }
}
