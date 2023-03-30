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

public enum TextValue: Codable, CustomStringConvertible, ExpressibleByStringLiteral, Hashable {
    case literal(key: String)
    case verbatim(content: String)
    case property(name: String, localize: Bool)
    case data(keyPath: String)
    
    public init(_ key: String) {
        self = .literal(key: key)
    }
    
    public init(stringLiteral: String) {
        self = .literal(key: stringLiteral)
    }
    
    public var description: String {
        switch self {
        case .literal(let key):
            return key
        case .verbatim(let content):
            return content
        case .property(let name, _):
            return name
        case .data(let keyPath):
            return keyPath
        }
    }
    
    public var isAttached: Bool {
        switch self {
        case .property, .data:
            return true
        case .literal, .verbatim:
            return false
        }
    }
        
    public var isLocalized: Bool {
        switch self {
        case .literal:
            return true
        case .verbatim:
            return false
        case .property(_, let localize):
            return localize
        case .data:
            return false
        }
    }

    public var isEmpty: Bool {
        description.isEmpty
    }
}

extension TextValue {
    public func resolve(
        data: Any?,
        properties: MainComponent.Properties,
        locale: Locale?,
        localizations: DocumentLocalizations
    ) -> String {
        switch self {
        case .literal(let key):
            return localize(
                key: key,
                locale: locale,
                localizations: localizations
            )
        case .verbatim(let content):
            return content
        case .property(let name, let localize):
            switch properties[name] {
            case .text(let value):
                if localize {
                    return self.localize(
                        key: value,
                        locale: locale,
                        localizations: localizations
                    )
                } else {
                    return value
                }
            case .number(let value):
                if #available(macOS 12.0, iOS 15.0, *) {
                    return value.formatted()
                } else {
                    return "\(value)"
                }
            case .boolean, .image, .component, .none:
                return ""
            }
        case .data(let keyPath):
            let value = JSONSerialization.value(
                forKeyPath: keyPath,
                data: data,
                properties: properties
            )

            switch value {
            case let string as NSString:
                return string as String
            case let number as NSNumber:
                if #available(macOS 12.0, iOS 15.0, *) {
                    return number.doubleValue.formatted()
                } else {
                    return "\(number.doubleValue)"
                }
            default:
                return ""
            }
        }
    }

    private func localize(
        key: String,
        locale: Locale?,
        localizations: DocumentLocalizations
    ) -> String {
        // A simple (and not complete) attempt at RFC 4647 basic filtering.
        guard let localeIdentifier = locale?.identifier else {
            return key
        }

        if let matchedLocale = localizations[localeIdentifier], let translation = matchedLocale[key] {
            return translation
        }

        if  let languageCode = Locale(identifier: localeIdentifier).languageCode,
            let matchedLocale = localizations.fuzzyMatch(key: languageCode),
            let translation = matchedLocale[key] {
            return translation
        }

        return key
    }
}
