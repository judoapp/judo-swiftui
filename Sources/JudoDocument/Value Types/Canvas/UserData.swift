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

public struct UserData: Codable {
    public var expandedNodeIDs: Set<UUID>
    public var zoomScale: CGFloat
    public var scrollOffset: CGPoint
    public var simulateSlowNetwork: Bool
    
    public init() {
        expandedNodeIDs = []
        zoomScale = 1.0
        scrollOffset = .zero
        simulateSlowNetwork = false
    }
    
    public init(
        expandedNodeIDs: Set<UUID>,
        zoomScale: CGFloat,
        scrollOffset: CGPoint,
        simulateSlowNetwork: Bool
    ) {
        self.expandedNodeIDs = expandedNodeIDs
        self.zoomScale = zoomScale
        self.scrollOffset = scrollOffset
        self.simulateSlowNetwork = simulateSlowNetwork
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case expandedNodeIDs
        case zoomScale
        case scrollOffset
        case simulateSlowNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        expandedNodeIDs = try container.decode(Set<UUID>.self, forKey: .expandedNodeIDs)
        zoomScale = try container.decode(CGFloat.self, forKey: .zoomScale)
        scrollOffset = try container.decode(CGPoint.self, forKey: .scrollOffset)
        simulateSlowNetwork = try container.decode(Bool.self, forKey: .simulateSlowNetwork)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expandedNodeIDs, forKey: .expandedNodeIDs)
        try container.encode(zoomScale, forKey: .zoomScale)
        try container.encode(scrollOffset, forKey: .scrollOffset)
        try container.encode(simulateSlowNetwork, forKey: .simulateSlowNetwork)
    }
}
