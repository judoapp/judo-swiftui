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

public struct FrameModifier: Modifier {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var frameType: FrameType
    public var width: Variable<Double>?
    public var minWidth: Variable<Double>?
    public var maxWidth: Variable<Double>?
    public var height: Variable<Double>?
    public var minHeight: Variable<Double>?
    public var maxHeight: Variable<Double>?
    public var alignment: Alignment

    public init(id: UUID, name: String?, children: [Node], frameType: FrameType, width: Variable<Double>?, minWidth: Variable<Double>?, maxWidth: Variable<Double>?, height: Variable<Double>?, minHeight: Variable<Double>?, maxHeight: Variable<Double>?, alignment: Alignment) {
        self.id = id
        self.name = name
        self.children = children
        self.frameType = frameType
        self.width = width
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.height = height
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
        case frameType
        case width
        case minWidth
        case maxWidth
        case height
        case minHeight
        case maxHeight
        case alignment
        
        // ..<16
        case frame
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<16:
            let frame = try container.decode(LegacyFrame.self, forKey: .frame)

            let isFlexible = frame.minWidth != nil || frame.maxWidth != nil || frame.minHeight != nil || frame.maxHeight != nil

            if isFlexible {
                self.frameType = .flexible

                self.minWidth = frame.minWidth.map { Variable(Double($0)) }
                self.maxWidth = frame.maxWidth.map { Variable(Double($0)) }
                self.minHeight = frame.minHeight.map { Variable(Double($0)) }
                self.maxHeight = frame.maxHeight.map { Variable(Double($0)) }
            } else {
                self.frameType = .fixed

                self.width = frame.width.map { Variable(Double($0)) }
                self.height = frame.height.map { Variable(Double($0)) }
            }

            alignment = frame.alignment
        case ..<17:
            var minWidthOrNil: Variable<Double>?
            var maxWidthOrNil: Variable<Double>?
            var minHeightOrNil: Variable<Double>?
            var maxHeightOrNil: Variable<Double>?

            if let minWidth = try container.decode(LegacyNumberValue?.self, forKey: .minWidth) {
                minWidthOrNil = Variable(minWidth)
            }

            if let maxWidth = try container.decode(LegacyNumberValue?.self, forKey: .maxWidth) {
                maxWidthOrNil = Variable(maxWidth)
            }

            if let minHeight = try container.decode(LegacyNumberValue?.self, forKey: .minHeight) {
                minHeightOrNil = Variable(minHeight)
            }

            if let maxHeight = try container.decode(LegacyNumberValue?.self, forKey: .maxHeight) {
                maxHeightOrNil = Variable(maxHeight)
            }

            // Check that the values are not nil
            let isFlexible = minWidthOrNil != nil || maxWidthOrNil != nil || minHeightOrNil != nil || maxHeightOrNil != nil

            if isFlexible {
                self.frameType = .flexible

                self.minWidth = minWidthOrNil
                self.maxWidth = maxWidthOrNil
                self.minHeight = minHeightOrNil
                self.maxHeight = maxHeightOrNil

            } else {
                self.frameType = .fixed
                
                if let width = try container.decode(LegacyNumberValue?.self, forKey: .width) {
                    self.width = Variable(width)
                }
                
                if let height = try container.decode(LegacyNumberValue?.self, forKey: .height) {
                    self.height = Variable(height)
                }
            }
            
            alignment = try container.decode(Alignment.self, forKey: .alignment)
        default:
            frameType = try container.decode(FrameType.self, forKey: .frameType)
            width = try container.decode(Variable<Double>?.self, forKey: .width)
            maxWidth = try container.decode(Variable<Double>?.self, forKey: .maxWidth)
            minWidth = try container.decode(Variable<Double>?.self, forKey: .minWidth)
            height = try container.decode(Variable<Double>?.self, forKey: .height)
            maxHeight = try container.decode(Variable<Double>?.self, forKey: .maxHeight)
            minHeight = try container.decode(Variable<Double>?.self, forKey: .minHeight)
            alignment = try container.decode(Alignment.self, forKey: .alignment)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(frameType, forKey: .frameType)
        try container.encode(width, forKey: .width)
        try container.encode(maxWidth, forKey: .maxWidth)
        try container.encode(minWidth, forKey: .minWidth)
        try container.encode(height, forKey: .height)
        try container.encode(maxHeight, forKey: .maxHeight)
        try container.encode(minHeight, forKey: .minHeight)
        try container.encode(alignment, forKey: .alignment)
    }
}
