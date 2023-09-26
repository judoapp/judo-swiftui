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

public final class Parameter: JudoObject {
    @Published public var key: String
    @Published public var textValue: Variable<String>?
    @Published public var numberValue: Variable<Double>?
    @Published public var booleanValue: Variable<Bool>?
    
    public init(key: String, textValue: Variable<String>) {
        self.textValue = textValue
        self.key = key
        super.init()
    }
    
    public init(key: String, numberValue: Variable<Double>) {
        self.numberValue = numberValue
        self.key = key
        super.init()
    }
    
    public init(key: String, booleanValue: Variable<Bool>) {
        self.booleanValue = booleanValue
        self.key = key
        super.init()
    }
    
    public required init() {
        self.key = "Key"
        self.textValue = "Value"
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any? = nil, fetchedImage: SwiftUI.Image? = nil, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.textValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.numberValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.booleanValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let parameter = super.copy(with: zone) as! Parameter
        parameter.key = key
        parameter.textValue = textValue
        parameter.numberValue = numberValue
        parameter.booleanValue = booleanValue
        return parameter
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case key
        case textValue
        case numberValue
        case booleanValue
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        key = try container.decode(String.self, forKey: .key)

        switch coordinator.documentVersion {
        case ..<17:
            if let value = try container.decode(LegacyTextValue?.self, forKey: .textValue) {
                self.textValue = Variable(value)
            }

            if let value = try container.decode(LegacyNumberValue?.self, forKey: .numberValue) {
                self.numberValue = Variable(value)
            }

            if let value = try container.decode(LegacyBooleanValue?.self, forKey: .booleanValue) {
                self.booleanValue = Variable(value)
            }

        default:
            textValue = try container.decode(Variable<String>?.self, forKey: .textValue)
            numberValue = try container.decode(Variable<Double>?.self, forKey: .numberValue)
            booleanValue = try container.decode(Variable<Bool>?.self, forKey: .booleanValue)
        }

        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(textValue, forKey: .textValue)
        try container.encode(numberValue, forKey: .numberValue)
        try container.encode(booleanValue, forKey: .booleanValue)
        try super.encode(to: encoder)
    }
}
