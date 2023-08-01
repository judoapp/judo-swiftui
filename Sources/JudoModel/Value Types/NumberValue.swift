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

public enum NumberValue: Codable, CustomStringConvertible, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable {

    case constant(value: Double)
    case property(name: String)
    case data(keyPath: String)

    public init(_ floatValue: CGFloat) {
        self = .constant(value: Double(floatValue))
    }

    public init(_ doubleValue: Double) {
        self = .constant(value: doubleValue)
    }

    public init(floatLiteral value: FloatLiteralType) {
        self = .constant(value: value)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self = .constant(value: Double(value))
    }

    public init(_ intValue: Int) {
        self = .constant(value: Double(intValue))
    }

    public var description: String {
        switch self {
        case .constant(let value):
            return "\(value)"
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
    ) -> Double? {
        switch self {
        case .constant(let value):
            return value
        case .property(let name):
            switch properties[name] {
            case .number(let value):
                return value
            case .text, .image, .component, .none, .boolean:
                return nil
            }
        case .data(let keyPath):
            let value = JSONSerialization.value(
                forKeyPath: keyPath,
                data: data,
                properties: properties
            )
            switch value {
            case let number as NSNumber:
                return number.doubleValue
            default:
                return nil
            }
        }
    }

}

