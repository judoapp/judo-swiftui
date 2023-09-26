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

public class OffsetModifier: JudoModifier {
    @Published public var width: Variable<Double> = 0
    @Published public var height: Variable<Double> = 0

    public required init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.width, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.height, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! OffsetModifier
        modifier.width = width
        modifier.height = height
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case width
        case height

        // ..<15
        case size
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        switch coordinator.documentVersion {
        case ..<15:
            let size = try container.decode(CGSize.self, forKey: .size)
            width = Variable(LegacyNumberValue(size.width))
            height = Variable(LegacyNumberValue(size.height))
        case ..<17:
            width = try Variable(container.decode(LegacyNumberValue.self, forKey: .width))
            height = try Variable(container.decode(LegacyNumberValue.self, forKey: .height))
        default:
            width = try container.decode(Variable<Double>.self, forKey: .width)
            height = try container.decode(Variable<Double>.self, forKey: .height)
        }

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try super.encode(to: encoder)
    }
}

