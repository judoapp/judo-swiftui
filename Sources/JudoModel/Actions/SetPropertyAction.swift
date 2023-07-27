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

public final class SetPropertyAction: PropertyAction {
    @Published public var textValue: TextValue?
    @Published public var numberValue: NumberValue?
    @Published public var booleanValue: BooleanValue?
    @Published public var imageValue: ImageValue?
    
    public init(propertyName: String, textValue: TextValue) {
        self.textValue = textValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, numberValue: NumberValue) {
        self.numberValue = numberValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, booleanValue: BooleanValue) {
        self.booleanValue = booleanValue
        super.init(propertyName: propertyName)
    }
    
    public init(propertyName: String, imageValue: ImageValue) {
        self.imageValue = imageValue
        super.init(propertyName: propertyName)
    }
    
    public required init() {
        self.textValue = "Value"
        super.init()
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
        textValue = try container.decode(TextValue?.self, forKey: .textValue)
        numberValue = try container.decode(NumberValue?.self, forKey: .numberValue)
        booleanValue = try container.decode(BooleanValue?.self, forKey: .booleanValue)
        imageValue = try container.decode(ImageValue?.self, forKey: .imageValue)
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
