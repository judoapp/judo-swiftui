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
            case text(LegacyTextValue)
            case number(LegacyNumberValue)
            case boolean(LegacyBooleanValue)
            case image(LegacyImageValue)
        }

        case set(property: String, value: Value)
        case toggle(property: String)
        case increment(property: String, value: LegacyNumberValue)
        case decrement(property: String, value: LegacyNumberValue)
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
    case openURL(LegacyTextValue)
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

            let value = try nestedContainer.decode(LegacyTextValue.self, forKey: ._0)
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
            return DismissAction(id: UUID())
        case .openURL(let url):
            return OpenURLAction(id: UUID(), url: Variable(url))
        case .refresh:
            return RefreshAction(id: UUID())
        case .property(let propertyAction):
            switch propertyAction {
            case .set(let propertyName, let value):
                switch value {
                case .text(let textValue):
                    return SetPropertyAction(
                        id: UUID(),
                        propertyName: propertyName,
                        textValue: Variable(textValue),
                        numberValue: nil,
                        booleanValue: nil,
                        imageValue: nil
                    )
                case .number(let numberValue):
                    return SetPropertyAction(
                        id: UUID(),
                        propertyName: propertyName,
                        textValue: nil,
                        numberValue: Variable(numberValue),
                        booleanValue: nil,
                        imageValue: nil
                    )
                case .boolean(let booleanValue):
                    return SetPropertyAction(
                        id: UUID(),
                        propertyName: propertyName,
                        textValue: nil,
                        numberValue: nil,
                        booleanValue: Variable(booleanValue),
                        imageValue: nil
                    )
                case .image(let imageValue):
                    return SetPropertyAction(
                        id: UUID(),
                        propertyName: propertyName,
                        textValue: nil,
                        numberValue: nil,
                        booleanValue: nil,
                        imageValue: Variable(imageValue)
                    )
                }
            case .toggle(let propertyName):
                return TogglePropertyAction(id: UUID(), propertyName: propertyName)
            case .increment(let propertyName, let value):
                return IncrementPropertyAction(id: UUID(), propertyName: propertyName, value: Variable(value))
            case .decrement(let propertyName, let value):
                return DecrementPropertyAction(id: UUID(), propertyName: propertyName, value: Variable(value))
            }
        case .custom(let legacyIdentifier, let legacyParameters):
            let parameters = legacyParameters.map { legacyParameter in
                switch legacyParameter.value {
                case .text(let stringValue):
                    return Parameter(
                        id: UUID(),
                        key: legacyParameter.key,
                        textValue: Variable(stringValue),
                        numberValue: nil,
                        booleanValue: nil
                    )
                case .number(let doubleValue):
                    return Parameter(
                        id: UUID(),
                        key: legacyParameter.key,
                        textValue: nil,
                        numberValue: Variable(doubleValue),
                        booleanValue: nil
                    )
                case .boolean(let boolValue):
                    return Parameter(
                        id: UUID(),
                        key: legacyParameter.key,
                        textValue: nil,
                        numberValue: nil,
                        booleanValue: Variable(boolValue)
                    )
                }
            }
            
            let identifier = Variable(legacyIdentifier.rawValue)
            return CustomAction(id: UUID(), identifier: identifier, parameters: parameters)
        }
    }
}
