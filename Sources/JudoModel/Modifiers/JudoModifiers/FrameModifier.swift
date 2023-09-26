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
    public enum FrameType: Codable {
        case fixed
        case flexible
    }
    
    @Published public private(set) var frameType: FrameType = .fixed
    
    @Published public private(set) var width: Variable<Double>?
    @Published public private(set) var minWidth: Variable<Double>?
    @Published public private(set) var maxWidth: Variable<Double>?
    
    @Published public private(set) var height: Variable<Double>?
    @Published public private(set) var minHeight: Variable<Double>?
    @Published public private(set) var maxHeight: Variable<Double>?
    
    @Published public var alignment: Alignment = .center

    public required init() {
        super.init()
    }
    
    // MARK: Modifiers
    
    public func changeType(to newType: FrameType, undoManager: UndoManager?) {
        let currentType = self.frameType
        switch (currentType, newType) {
        case (.fixed, .flexible):
            resize(
                minWidth: nil,
                maxWidth: width,
                minHeight: nil,
                maxHeight: height,
                undoManager: undoManager
            )
        case (.flexible, .fixed):
            resize(
                width: maxWidth,
                height: maxHeight,
                undoManager: undoManager
            )
        default:
            break
        }
    }
    
    public func resize(
        width: Variable<Double>?,
        height: Variable<Double>?,
        undoManager: UndoManager?
    ) {
        set(\.frameType, to: .fixed, undoManager: undoManager)
        
        set(\.width, to: width, undoManager: undoManager)
        set(\.minWidth, to: nil, undoManager: undoManager)
        set(\.maxWidth, to: nil, undoManager: undoManager)
        
        set(\.height, to: height, undoManager: undoManager)
        set(\.minHeight, to: nil, undoManager: undoManager)
        set(\.maxHeight, to: nil, undoManager: undoManager)
    }
    
    public func resize(
        minWidth: Variable<Double>?,
        maxWidth: Variable<Double>?,
        minHeight: Variable<Double>?,
        maxHeight: Variable<Double>?,
        undoManager: UndoManager?
    ) {
        set(\.frameType, to: .flexible, undoManager: undoManager)
        
        set(\.width, to: nil, undoManager: undoManager)
        set(\.minWidth, to: minWidth, undoManager: undoManager)
        set(\.maxWidth, to: maxWidth, undoManager: undoManager)
        
        set(\.height, to: nil, undoManager: undoManager)
        set(\.minHeight, to: minHeight, undoManager: undoManager)
        set(\.maxHeight, to: maxHeight, undoManager: undoManager)
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.width, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.maxWidth, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.minWidth, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.height, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.maxHeight, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.minHeight, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! FrameModifier
        modifier.frameType = frameType
        modifier.width = width
        modifier.minWidth = minWidth
        modifier.maxWidth = maxWidth
        modifier.height = height
        modifier.minHeight = minHeight
        modifier.maxHeight = maxHeight
        modifier.alignment = alignment
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
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

    public required init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch coordinator.documentVersion {
        case ..<16:
            let frame = try container.decode(LegacyFrame.self, forKey: .frame)
            width = frame.width.map { Variable(Double($0)) }
            maxWidth = frame.maxWidth.map { Variable(Double($0)) }
            minWidth = frame.minWidth.map { Variable(Double($0)) }
            height = frame.height.map { Variable(Double($0)) }
            maxHeight = frame.maxHeight.map { Variable(Double($0)) }
            minHeight = frame.minHeight.map { Variable(Double($0)) }
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
        
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frameType, forKey: .frameType)
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
