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

public enum AngleUnit: Codable {
    case degrees
    case radians
}

public class RotationEffectModifier: JudoModifier {

    @Published public var angleSize: Variable<Double> = 0
    @Published public var angleUnit: AngleUnit = .degrees
    @Published public var anchor: UnitPoint = .center

    public required init() {
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.angleSize, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! RotationEffectModifier
        modifier.angleSize = angleSize
        modifier.angleUnit = angleUnit
        modifier.anchor = anchor
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case angleSize
        case angleUnit
        case anchor
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        angleSize = try container.decode(Variable<Double>.self, forKey: .angleSize)
        angleUnit = try container.decode(AngleUnit.self, forKey: .angleUnit)
        anchor = try container.decode(UnitPoint.self, forKey: .anchor)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(angleSize, forKey: .angleSize)
        try container.encode(angleUnit, forKey: .angleUnit)
        try container.encode(anchor, forKey: .anchor)
        try super.encode(to: encoder)
    }
}
