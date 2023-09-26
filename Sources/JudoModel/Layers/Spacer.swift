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

import Foundation
import SwiftUI

public final class Spacer: Layer, Modifiable {

    @Published public dynamic var minLength: Variable<Double>?
    
    required public init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.minLength, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let text = super.copy(with: zone) as! Spacer
        text.minLength = self.minLength
        return text
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case minLength
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<15:
            if let floatValue = try container.decodeIfPresent(CGFloat.self, forKey: .minLength) {
                minLength = Variable(LegacyNumberValue(floatValue))
            }
        case ..<17:
            if let numberValue = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .minLength) {
                minLength = Variable(numberValue)
            }
        default:
            minLength = try container.decodeIfPresent(Variable<Double>.self, forKey: .minLength)
        }
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minLength, forKey: .minLength)
        try super.encode(to: encoder)
    }
}
