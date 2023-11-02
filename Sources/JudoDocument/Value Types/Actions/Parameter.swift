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

public struct Parameter: Codable {
    public var id: UUID
    public var key: String
    public var textValue: Variable<String>?
    public var numberValue: Variable<Double>?
    public var booleanValue: Variable<Bool>?
    
    public init(id: UUID, key: String, textValue: Variable<String>?, numberValue: Variable<Double>?, booleanValue: Variable<Bool>?) {
        self.id = id
        self.key = key
        self.textValue = textValue
        self.numberValue = numberValue
        self.booleanValue = booleanValue
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case textValue
        case numberValue
        case booleanValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta

        id = try container.decode(UUID.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)

        switch meta.version {
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(textValue, forKey: .textValue)
        try container.encode(numberValue, forKey: .numberValue)
        try container.encode(booleanValue, forKey: .booleanValue)
    }
}
