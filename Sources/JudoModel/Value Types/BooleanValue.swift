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

public enum BooleanValue: Codable, CustomStringConvertible, ExpressibleByBooleanLiteral, Hashable {
    case constant(value: Bool)
    case property(name: String)
    case data(keyPath: String)

    public init(booleanLiteral value: BooleanLiteralType) {
        self = .constant(value: value)
    }

    public var description: String {
        switch self {
        case .constant(let value):
            return value ? "true" : "false"
        case .property(let name):
            return name
        case .data(let keyPath):
            return keyPath
        }
    }

    public var isAttached: Bool {
        switch self {
        case .property, .data:
            return true
        case .constant:
            return false
        }
    }

    public func resolve(
        data: Any?,
        properties: MainComponent.Properties
    ) -> Bool {
        switch self {
        case .constant(let value):
            return value
        case .property(let name):
            switch properties[name] {
            case .boolean(let value):
                return value
            case .number(let value):
                return NSNumber(value: value).boolValue
            case .text, .image, .component, .none:
                return false
            }
        case .data(let keyPath):
            let value = JSONSerialization.value(
                forKeyPath: keyPath,
                data: data,
                properties: properties
            )
            switch value {
            case let bool as Bool:
                return bool
            case let number as NSNumber:
                return number.boolValue
            default:
                return false
            }
        }
    }

}
