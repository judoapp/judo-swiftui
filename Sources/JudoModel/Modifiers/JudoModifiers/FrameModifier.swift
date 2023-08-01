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

public class FrameModifier: JudoModifier {
    @Published public var width: NumberValue?
    @Published public var maxWidth: NumberValue?
    @Published public var minWidth: NumberValue?
    @Published public var height: NumberValue?
    @Published public var maxHeight: NumberValue?
    @Published public var minHeight: NumberValue?
    @Published public var alignment: Alignment = .center

    public required init() {
        super.init()
    }
    
    public var isFlexible: Bool {
        [maxWidth, minWidth, maxHeight, minHeight].contains {
            $0 != nil
        }
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! FrameModifier
        modifier.width = width
        modifier.maxWidth = maxWidth
        modifier.minWidth = minWidth
        modifier.height = height
        modifier.maxHeight = maxHeight
        modifier.minHeight = minHeight
        modifier.alignment = alignment
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case width
        case maxWidth
        case minWidth
        case height
        case maxHeight
        case minHeight
        case alignment
        
        // ..<16
        case frame
    }

    public required init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch coordinator.documentVersion {
        case ..<16:
            let frame = try container.decode(LegacyFrame.self, forKey: .frame)
            width = frame.width.map { .constant(value: Double($0)) }
            maxWidth = frame.maxWidth.map { .constant(value: Double($0)) }
            minWidth = frame.minWidth.map { .constant(value: Double($0)) }
            height = frame.height.map { .constant(value: Double($0)) }
            maxHeight = frame.maxHeight.map { .constant(value: Double($0)) }
            minHeight = frame.minHeight.map { .constant(value: Double($0)) }
            alignment = frame.alignment
        default:
            width = try container.decode(NumberValue?.self, forKey: .width)
            maxWidth = try container.decode(NumberValue?.self, forKey: .maxWidth)
            minWidth = try container.decode(NumberValue?.self, forKey: .minWidth)
            height = try container.decode(NumberValue?.self, forKey: .height)
            maxHeight = try container.decode(NumberValue?.self, forKey: .maxHeight)
            minHeight = try container.decode(NumberValue?.self, forKey: .minHeight)
            alignment = try container.decode(Alignment.self, forKey: .alignment)
        }
        
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(maxWidth, forKey: .maxWidth)
        try container.encode(minWidth, forKey: .minWidth)
        try container.encode(height, forKey: .height)
        try container.encode(maxHeight, forKey: .maxHeight)
        try container.encode(minHeight, forKey: .minHeight)
        try container.encode(alignment, forKey: .alignment)
        try super.encode(to: encoder)
    }
}
