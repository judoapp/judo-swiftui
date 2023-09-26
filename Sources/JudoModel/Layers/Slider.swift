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

public final class Slider: Layer, Modifiable {

    @Published public var label: Variable<String> = Variable(Slider.humanName)
    @Published public var minLabel: Variable<String>?
    @Published public var maxLabel: Variable<String>?
    @Published public var value: Variable<Double> = 0.0
    @Published public var minValue: Variable<Double>?
    @Published public var maxValue: Variable<Double>?
    @Published public var step: Variable<Double>?

    required public init() {
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.label, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.minLabel, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.maxLabel, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.value, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.minValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.maxValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.step, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let layerCopy = super.copy(with: zone) as! Self
        layerCopy.label = label
        layerCopy.minLabel = minLabel
        layerCopy.maxLabel = maxLabel
        layerCopy.value = value
        layerCopy.minValue = minValue
        layerCopy.maxValue = maxValue
        layerCopy.step = step
        return layerCopy
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case minLabel
        case maxLabel
        case value
        case minValue
        case maxValue
        case step
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator


        switch coordinator.documentVersion {
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

        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(minLabel, forKey: .minLabel)
        try container.encode(maxLabel, forKey: .maxLabel)
        try container.encode(value, forKey: .value)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(step, forKey: .step)
        try super.encode(to: encoder)
    }
}

