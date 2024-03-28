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
import JudoExpressions

/// The class used to dynamically evaluate expressions.
/// An expression is a combination of values, variables, and operations that represents a calculation.
public struct Expression<T: Codable & Hashable & CustomStringConvertible>: Hashable, CustomStringConvertible, CustomDebugStringConvertible, Codable {
    /// Expression value
    public let expression: String

    public var description: String {
        expression
    }

    public var debugDescription: String {
        expression
    }

    public func resolve(propertyValues: [String: PropertyValue], data: Any? = nil) -> T? {
        try? evaluate(propertyValues: propertyValues, data: data)
    }

    /// Evaluates an expression using a specified properties and functions.
    func evaluate(propertyValues: [String: PropertyValue], data: Any?, functions: [JudoExpressionFunction] = []) throws -> T? {
        var variables = propertyValues.compactMap { element in
            switch element.value {
            case .number(let doubleValue):
                return JudoExpressionVariable(element.key, value: doubleValue)
            case .text(let stringValue):
                return JudoExpressionVariable(element.key, value: stringValue)
            case .boolean(let boolValue):
                return JudoExpressionVariable(element.key, value: boolValue)
            case .computed(let computedValue):

                // replace expression with resulting value
                var propertyValues = propertyValues
                propertyValues.removeValue(forKey: element.key)

                switch computedValue {
                case .number(let expression):
                    return try? JudoExpressionVariable(element.key, value: expression.evaluate(propertyValues: propertyValues, data: data, functions: functions))
                case .text(let expression):
                    return try? JudoExpressionVariable(element.key, value: expression.evaluate(propertyValues: propertyValues, data: data, functions: functions))
                case .boolean(let expression):
                    if let evaluatedValue = try? expression.evaluate(propertyValues: propertyValues, data: data, functions: functions) {
                        return JudoExpressionVariable(element.key, value: evaluatedValue)
                    } else {
                        return nil
                    }
                }
            default:
                return nil
            }
        }

        if let data {
            variables += dataVariables(value: data, keyPath: ["data"]) ?? []
        }

        return try evaluate(variables: variables, functions: functions)
    }

    /// Evaluates an expression using a specified variables and functions.
    func evaluate(variables: [JudoExpressions.JudoExpressionVariable] = [], functions: [JudoExpressionFunction] = []) throws -> T? {
        try JudoInterpreter(variables: variables, functions: functions).interpret(expression) as? T
    }

    private func dataVariables(value: Any, keyPath: [String]) -> [JudoExpressionVariable]? {
        switch value {
        case let number as Double:
            return [JudoExpressionVariable(keyPath.joined(separator: "\u{B7}"), value: number)]
        case let string as String:
            return [JudoExpressionVariable(keyPath.joined(separator: "\u{B7}"), value: string)]
        case let dictionary as [String: Any]:
            return dictionary.reduce(into: [JudoExpressionVariable]()) { partialResult, element in
                let keyPath = keyPath + [element.key]
                partialResult += dataVariables(value: element.value, keyPath: keyPath) ?? []
            }
        default:
            return nil
        }

    }

}

extension Expression<String>: ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral {

    /// Creates the expression with the specified string.
    public init(_ expression: String) {
        self.expression = expression
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(expression: "\"\(value)\"")
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(expression: "\"\(value)\"")
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(expression: "\"\(value)\"")
    }
}

extension Expression<Double>: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

    /// Creates the expression with the specified number.
    public init(_ expression: String) {
        self.expression = expression
    }

    public init(floatLiteral value: FloatLiteralType) {
        self.init(expression: numberFormatter.string(from: value as NSNumber) ?? "\(value)")
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(floatLiteral: Double(value))
    }
}

extension Expression<Bool>: ExpressibleByBooleanLiteral {

    /// Creates the expression with the specified number.
    public init(_ expression: String) {
        self.expression = expression
    }

    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(expression: value ? "true" : "false")
    }
}

/// Library of standard functions
private let standardLibrary = [
    JudoExpressionFunction("formatted", closure: { caller, _ in
        guard let value = caller as? Double else {
            return caller
        }

        if #available(macOS 12.0, iOS 15.0, *) {
            return value.formatted(.number.precision(.fractionLength(0...2)))
        } else {
            return NumberFormatter.localizedString(from: value as NSNumber, number: .none)
        }
    })
]

private var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.decimalSeparator = "."
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = .none
    formatter.allowsFloats = true
    return formatter
}()
