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

public class AspectRatioModifier: JudoModifier {

    @Published public var ratio: Variable<Double>?
    @Published public var contentMode: ContentMode = .fit

    public required init() {
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.ratio, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! AspectRatioModifier
        modifier.ratio = ratio
        modifier.contentMode = contentMode
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case ratio
        case contentMode
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<15:
            if let floatValue = try container.decodeIfPresent(CGFloat.self, forKey: .ratio) {
                ratio = Variable(LegacyNumberValue(floatValue))
            }
        case ..<17:
            if let value = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .ratio) {
                ratio = Variable(value)
            }
        default:
            ratio = try container.decodeIfPresent(Variable<Double>.self, forKey: .ratio)
        }

        contentMode = try container.decode(ContentMode.self, forKey: .contentMode)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ratio, forKey: .ratio)
        try container.encode(contentMode, forKey: .contentMode)
        try super.encode(to: encoder)
    }
}

