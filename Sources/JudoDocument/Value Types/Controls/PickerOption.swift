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

public struct PickerOption: Codable {
    public var id: UUID
    public var title: Variable<String>?
    public var icon: Variable<ImageReference>?
    public var textValue: Variable<String>?
    public var numberValue: Variable<Double>?

    public init(
        id: UUID,
        title: Variable<String>?,
        icon: Variable<ImageReference>?,
        textValue: Variable<String>?,
        numberValue: Variable<Double>?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.textValue = textValue
        self.numberValue = numberValue
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case icon
        case textValue
        case numberValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta
        id = try container.decode(UUID.self, forKey: .id)

        switch meta.version {
        case ..<17:
            if let icon = try container.decode(LegacyImageValue?.self, forKey: .icon) {
                self.icon = Variable(icon)
            }

            if let title = try container.decode(LegacyTextValue?.self, forKey: .title) {
                self.title = Variable(title)
            }

            if let textValue = try container.decode(LegacyTextValue?.self, forKey: .textValue) {
                self.textValue = Variable(textValue)
            }

            if let value = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .numberValue) {
                numberValue = Variable(value)
            }
        default:
            icon = try container.decode(Variable<ImageReference>?.self, forKey: .icon)
            title = try container.decode(Variable<String>?.self, forKey: .title)
            textValue = try container.decode(Variable<String>?.self, forKey: .textValue)
            numberValue = try container.decodeIfPresent(Variable<Double>.self, forKey: .numberValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(textValue, forKey: .textValue)
        try container.encode(numberValue, forKey: .numberValue)
    }
}
