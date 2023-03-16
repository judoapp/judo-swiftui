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

import CoreGraphics
import SwiftUI

public struct GradientValue: Equatable, Hashable {
    public struct Stop: Equatable, Codable, Hashable {
        public var color: ColorValue
        public var position: Double
        
        public init(color: ColorValue, position: Double) {
            self.color = color
            self.position = position
        }
    }
    
    /// In a parametric coordinate space, between 0 and 1.
    public var from: CGPoint
    
    /// In a parametric coordinate space, between 0 and 1.
    public var to: CGPoint
    
    public var stops: [Stop]
    
    public init(from: CGPoint, to: CGPoint, stops: [Stop]) {
        self.from = from
        self.to = to
        self.stops = stops
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(from.x)
        hasher.combine(from.y)
        hasher.combine(to.x)
        hasher.combine(to.y)
        hasher.combine(stops)
    }
    
    public static var `default`: GradientValue {
        GradientValue(
            from: CGPoint(x: 0.5, y: 0),
            to: CGPoint(x: 0.5, y: 1),
            stops: [
                Stop(color: .white, position: 0),
                Stop(color: .red, position: 1)
            ]
        )
    }
    
    public static var clear: GradientValue {
        GradientValue(
            from: CGPoint(x: 0.5, y: 0),
            to: CGPoint(x: 0.5, y: 1),
            stops: [
                Stop(color: .clear, position: 0),
                Stop(color: .clear, position: 1)
            ]
        )
    }
}

extension GradientValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case stops
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(
            stops.sorted { $0.position < $1.position },
            forKey: .stops
        )
    }
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        from = try container.decodeIfPresent(CGPoint.self, forKey: .from) ?? .zero
        to = try container.decodeIfPresent(CGPoint.self, forKey: .to) ?? .zero
        stops = try container.decodeIfPresent([Stop].self, forKey: .stops) ?? []
    }
}
