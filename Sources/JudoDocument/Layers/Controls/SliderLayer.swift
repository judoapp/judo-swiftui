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

public struct SliderLayer: Layer {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var frame: Frame
    public var isLocked: Bool
    public var label: Variable<String>
    public var minLabel: Variable<String>?
    public var maxLabel: Variable<String>?
    public var value: Variable<Double>
    public var minValue: Variable<Double>?
    public var maxValue: Variable<Double>?
    public var step: Variable<Double>?

    public init(id: UUID, name: String?, children: [Node], position: CGPoint, frame: Frame, isLocked: Bool, label: Variable<String>, minLabel: Variable<String>?, maxLabel: Variable<String>?, value: Variable<Double>, minValue: Variable<Double>?, maxValue: Variable<Double>?, step: Variable<Double>?) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.frame = frame
        self.isLocked = isLocked
        self.label = label
        self.minLabel = minLabel
        self.maxLabel = maxLabel
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case frame
        case isLocked
        case label
        case minLabel
        case maxLabel
        case value
        case minValue
        case maxValue
        case step
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)

        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<23:
            frame = Frame()
        default:
            frame = try container.decode(Frame.self, forKey: .frame)
        }

        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false

        switch meta.version {
        case ..<17:
            label = try Variable(container.decode(LegacyTextValue.self, forKey: .label))

            if let minLabel = try container.decode(LegacyTextValue?.self, forKey: .minLabel) {
                self.minLabel = Variable(minLabel)
            }

            if let maxLabel = try container.decode(LegacyTextValue?.self, forKey: .maxLabel) {
                self.maxLabel = Variable(maxLabel)
            }

            value = try Variable(container.decode(LegacyNumberValue.self, forKey: .value))

            if let numberValue = try container.decode(LegacyNumberValue?.self, forKey: .minValue) {
                minValue = Variable(numberValue)
            }

            if let numberValue = try container.decode(LegacyNumberValue?.self, forKey: .maxValue) {
                maxValue = Variable(numberValue)
            }

            if let numberValue = try container.decode(LegacyNumberValue?.self, forKey: .step) {
                step = Variable(numberValue)
            }
        default:
            label = try container.decode(Variable<String>.self, forKey: .label)
            minLabel = try container.decode(Variable<String>?.self, forKey: .minLabel)
            maxLabel = try container.decode(Variable<String>?.self, forKey: .maxLabel)
            value = try container.decode(Variable<Double>.self, forKey: .value)
            minValue = try container.decode(Variable<Double>?.self, forKey: .minValue)
            maxValue = try container.decode(Variable<Double>?.self, forKey: .maxValue)
            step = try container.decode(Variable<Double>?.self, forKey: .step)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(frame, forKey: .frame)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(label, forKey: .label)
        try container.encode(minLabel, forKey: .minLabel)
        try container.encode(maxLabel, forKey: .maxLabel)
        try container.encode(value, forKey: .value)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(step, forKey: .step)
    }
}

