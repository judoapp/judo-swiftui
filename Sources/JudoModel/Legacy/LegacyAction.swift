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
import OrderedCollections

enum LegacyAction: Decodable {
    enum LegacyPropertyAction: Decodable {
        enum Value: Decodable {
            case text(TextValue)
            case number(NumberValue)
            case boolean(BooleanValue)
            case image(ImageValue)
        }

        case set(property: String, value: Value)
        case toggle(property: String)
        case increment(property: String, value: NumberValue)
        case decrement(property: String, value: NumberValue)
    }

    typealias LegacyParameters = OrderedDictionary<String, LegacyParameterValue>

    struct LegacyCustomActionIdentifier: Decodable {
        let rawValue: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }
    }
    
    enum LegacyParameterValue: Decodable {
        case text(String)
        case number(Double)
        case boolean(Bool)
    }

    case dismiss
    case openURL(TextValue)
    case refresh
    case property(LegacyPropertyAction)
    case custom(LegacyCustomActionIdentifier, LegacyParameters)

    enum CodingKeys: CodingKey {
        case dismiss
        case openURL
        case refresh
        case property
        case custom

        // Legacy
        case none
    }

    enum NestedCodingKeys: CodingKey {
        case _0
        case _1
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var allKeys = ArraySlice(container.allKeys)

        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(
                LegacyAction.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one.",
                    underlyingError: nil
                )
            )
        }

        switch onlyKey {
        case .dismiss:
            self = .dismiss
        case .openURL:
            let nestedContainer = try container.nestedContainer(
                keyedBy: NestedCodingKeys.self,
                forKey: .openURL
            )

            let value = try nestedContainer.decode(TextValue.self, forKey: ._0)
            self = .openURL(value)
        case .refresh:
            self = .refresh
        case .property:
            let nestedContainer = try container.nestedContainer(
                keyedBy: NestedCodingKeys.self,
                forKey: .property
            )

            let value = try nestedContainer.decode(
                LegacyPropertyAction.self,
                forKey: ._0
            )

            self = .property(value)
        case .custom:
            let nestedContainer = try container.nestedContainer(
                keyedBy: NestedCodingKeys.self,
                forKey: .custom
            )

            let identifier = try nestedContainer.decode(
                LegacyCustomActionIdentifier.self,
                forKey: ._0
            )

            let parameters = try nestedContainer.decode(
                LegacyParameters.self,
                forKey: ._1
            )

            self = .custom(identifier, parameters)
        case .none:
            self = .dismiss
        }
    }
}

extension LegacyAction {
    var action: Action {
        switch self {
        case .dismiss:
            return DismissAction()
        case .openURL(let url):
            return OpenURLAction(url: url)
        case .refresh:
            return RefreshAction()
        case .property(let propertyAction):
            switch propertyAction {
            case .set(let propertyName, let value):
                switch value {
                case .text(let textValue):
                    return SetPropertyAction(propertyName: propertyName, textValue: textValue)
                case .number(let numberValue):
                    return SetPropertyAction(propertyName: propertyName, numberValue: numberValue)
                case .boolean(let booleanValue):
                    return SetPropertyAction(propertyName: propertyName, booleanValue: booleanValue)
                case .image(let imageValue):
                    return SetPropertyAction(propertyName: propertyName, imageValue: imageValue)
                }
            case .toggle(let propertyName):
                return TogglePropertyAction(propertyName: propertyName)
            case .increment(let propertyName, let value):
                return IncrementPropertyAction(propertyName: propertyName, value: value)
            case .decrement(let propertyName, let value):
                return DecrementPropertyAction(propertyName: propertyName, value: value)
            }
        case .custom(let legacyIdentifier, let legacyParameters):
            let parameters = legacyParameters.map { legacyParameter in
                switch legacyParameter.value {
                case .text(let stringValue):
                    return Parameter(key: legacyParameter.key, textValue: .verbatim(content: stringValue))
                case .number(let doubleValue):
                    return Parameter(key: legacyParameter.key, numberValue: .constant(value: doubleValue))
                case .boolean(let boolValue):
                    return Parameter(key: legacyParameter.key, booleanValue: .constant(value: boolValue))
                }
            }
            
            let identifier = TextValue.verbatim(content: legacyIdentifier.rawValue)
            return CustomAction(identifier: identifier, parameters: parameters)
        }
    }
}
