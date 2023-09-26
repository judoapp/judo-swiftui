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

public class LineLimitModifier: JudoModifier {
    @Published public var min: Variable<Double>? = nil
    @Published public var max: Variable<Double>? = 1

    public required init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.min, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.max, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! LineLimitModifier
        modifier.min = min
        modifier.max = max
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case min
        case max

        // ..<16
        case numberOfLines
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<16:
            if let intValue = try container.decode(Int?.self, forKey: .numberOfLines) {
                max = Variable(LegacyNumberValue(intValue))
            }
        case ..<17:
            if let value = try container.decode(LegacyNumberValue?.self, forKey: .min) {
                min = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .max) {
                max = Variable(value)
            }
        default:
            min = try container.decode(Variable<Double>?.self, forKey: .min)
            max = try container.decode(Variable<Double>?.self, forKey: .max)
        }

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(min, forKey: .min)
        try container.encode(max, forKey: .max)
        try super.encode(to: encoder)
    }
}

extension LineLimitModifier {

    /// Apply logic to output final range based on min, max values
    public func effectiveRange(minValue: Int?, maxValue: Int?) -> ClosedRange<Int>? {
        switch (minValue, maxValue) {
        case (.some(let minValue), nil):
            return minValue...Int.max
        case (.some(let minValue), .some(let maxValue)):
            if minValue <= maxValue {
                return minValue...maxValue
            } else {
                return nil // invalid range
            }
        case (nil, .some(let maxValue)):
            return 0...maxValue
        case (nil, nil):
            return nil
        }
    }

}
