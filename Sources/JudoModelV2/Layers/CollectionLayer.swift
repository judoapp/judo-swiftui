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

public final class CollectionLayer: Layer {
    override public class var humanName: String {
        "Collection"
    }
    
    public struct Limit: Codable, Hashable {
        public var show: Int {
            didSet {
                assert(show >= 1, "Must show at least one item")
                assert(show <= 100, "Can only show a maximum of 100 items")
            }
        }
        
        public var startAt: Int {
            didSet {
                assert(startAt >= 1, "Can not start before the first item")
            }
        }
        
        public init(show: Int = 30, startAt: Int = 1) {
            self.show = show
            self.startAt = startAt
        }
    }

    @Published public var keyPath = ""
    @Published public var filters = [Condition]()
    @Published public var sortDescriptors = [SortDescriptor]()
    @Published public var limit: Limit?
    
    required public init() {
        super.init()
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is Layer.Type:
            return true
        default:
            return false
        }
    }
    
    override public var traits: Traits {
        [
            .metadatable,
            .lockable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let collection = super.copy(with: zone) as! CollectionLayer
        collection.keyPath = keyPath
        collection.filters = filters
        collection.sortDescriptors = sortDescriptors
        collection.limit = limit
        return collection
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case keyPath
        case filters
        case sortDescriptors
        case limit
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyPath = try container.decode(String.self, forKey: .keyPath)
        filters = try container.decode([Condition].self, forKey: .filters)
        sortDescriptors = try container.decode([SortDescriptor].self, forKey: .sortDescriptors)
        limit = try container.decodeIfPresent(Limit.self, forKey: .limit)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyPath, forKey: .keyPath)
        try container.encode(filters, forKey: .filters)
        try container.encode(sortDescriptors, forKey: .sortDescriptors)
        try container.encodeIfPresent(limit, forKey: .limit)
        try super.encode(to: encoder)
    }
}
