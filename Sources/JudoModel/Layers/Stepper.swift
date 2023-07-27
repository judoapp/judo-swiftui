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

public final class Stepper: Layer, Modifiable {

    @Published public var label: TextValue = .verbatim(content: Stepper.humanName)
    @Published public var value: NumberValue = 0.0
    @Published public var minValue: NumberValue?
    @Published public var maxValue: NumberValue?
    @Published public var step: NumberValue?

    required public init() {
        super.init()
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let layerCopy = super.copy(with: zone) as! Self
        layerCopy.label = label
        layerCopy.value = value
        layerCopy.minValue = minValue
        layerCopy.maxValue = maxValue
        layerCopy.step = step
        return layerCopy
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case value
        case minValue
        case maxValue
        case step
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decode(TextValue.self, forKey: .label)
        value = try container.decode(NumberValue.self, forKey: .value)
        minValue = try container.decode(NumberValue?.self, forKey: .minValue)
        maxValue = try container.decode(NumberValue?.self, forKey: .maxValue)
        step = try container.decode(NumberValue?.self, forKey: .step)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(value, forKey: .value)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(step, forKey: .step)
        try super.encode(to: encoder)
    }
}
