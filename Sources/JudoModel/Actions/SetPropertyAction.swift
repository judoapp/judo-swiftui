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

public final class SetPropertyAction: PropertyAction {
    @Published public var textValue: Variable<String>?
    @Published public var numberValue: Variable<Double>?
    @Published public var booleanValue: Variable<Bool>?
    @Published public var imageValue: Variable<ImageReference>?
    
    public init(propertyName: String, textValue: Variable<String>) {
        self.textValue = textValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, numberValue: Variable<Double>) {
        self.numberValue = numberValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, booleanValue: Variable<Bool>) {
        self.booleanValue = booleanValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, imageValue: Variable<ImageReference>) {
        self.imageValue = imageValue
        super.init(propertyName: propertyName)
    }
    
    public required init() {
        self.textValue = "Value"
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.textValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.numberValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.booleanValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.imageValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let action = super.copy(with: zone) as! SetPropertyAction
        action.textValue = textValue
        action.numberValue = numberValue
        action.booleanValue = booleanValue
        action.imageValue = imageValue
        return action
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case textValue
        case numberValue
        case booleanValue
        case imageValue
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<17:
            if let textValue = try container.decode(LegacyTextValue?.self, forKey: .textValue) {
                self.textValue = Variable(textValue)
            }

            if let imageValue = try container.decode(LegacyImageValue?.self, forKey: .imageValue) {
                self.imageValue = Variable(imageValue)
            }

            if let numberValue = try container.decode(LegacyNumberValue?.self, forKey: .numberValue) {
                self.numberValue = Variable(numberValue)
            }

            if let booleanValue = try container.decode(LegacyBooleanValue?.self, forKey: .booleanValue) {
                self.booleanValue = Variable(booleanValue)
            }
        default:
            textValue = try container.decode(Variable<String>?.self, forKey: .textValue)
            imageValue = try container.decode(Variable<ImageReference>?.self, forKey: .imageValue)
            numberValue = try container.decode(Variable<Double>?.self, forKey: .numberValue)
            booleanValue = try container.decode(Variable<Bool>?.self, forKey: .booleanValue)
        }

        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(textValue, forKey: .textValue)
        try container.encode(numberValue, forKey: .numberValue)
        try container.encode(booleanValue, forKey: .booleanValue)
        try container.encode(imageValue, forKey: .imageValue)
        try super.encode(to: encoder)
    }
}
