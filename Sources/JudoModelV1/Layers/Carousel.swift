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

public class Carousel: Layer {
    public var isLoopEnabled = false {
        willSet { objectWillChange.send() }
    }
    
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
        case is CollectionNode.Type:
            return true
        case is WebViewNode.Type:
            return true
        default:
            return false
        }
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .resizable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .layerable,
            .accessible,
            .metadatable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let carousel = super.copy(with: zone) as! Carousel
        carousel.isLoopEnabled = isLoopEnabled
        return carousel
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case isLoopEnabled
        case hideOverflow
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isLoopEnabled = try container.decode(Bool.self, forKey: .isLoopEnabled)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isLoopEnabled, forKey: .isLoopEnabled)
        try super.encode(to: encoder)
    }
}
