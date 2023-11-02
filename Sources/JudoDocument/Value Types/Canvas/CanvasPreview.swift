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

public struct CanvasPreview: Codable, Hashable {
    public struct Frame: Codable, Hashable {
        public static let device = Frame(width: 375, height: nil, deviceBezels: true)
        public static let vertical = Frame(width: 375, height: nil, deviceBezels: false)
        public static let horizontal = Frame(width: nil, height: 200, deviceBezels: false)
        public static let none = Frame(width: 375, height: nil, deviceBezels: false)
        
        public var width: CGFloat?
        public var height: CGFloat?
        public var deviceBezels: Bool
        
        public init(width: CGFloat?, height: CGFloat?, deviceBezels: Bool) {
            self.width = width
            self.height = height
            self.deviceBezels = deviceBezels
        }
    }
    
    public enum Bar: String, Codable {
        case navigationBar
        case tabBar
    }
    
    public var frame: Frame
    public var bars: Set<Bar>
    
    public init(frame: Frame, bars: Set<Bar>) {
        self.frame = frame
        self.bars = bars
    }
    
    // MARK: Codable
    
    private enum CodingKeys: CodingKey {
        case frame
        case bars
        
        // Legacy
        case width
        case height
        case simulateDevice
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<14:
            let width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
            let height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
            let simulateDevice = try container.decode(Bool.self, forKey: .simulateDevice)
            
            frame = Frame(
                width: width,
                height: height,
                deviceBezels: simulateDevice
            )
            
            bars = []
        default:
            frame = try container.decode(Frame.self, forKey: .frame)
            bars = try container.decode(Set<Bar>.self, forKey: .bars)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.frame, forKey: .frame)
        try container.encode(self.bars, forKey: .bars)
    }
}
