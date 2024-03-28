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

private var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.decimalSeparator = "."
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = .none
    formatter.allowsFloats = true
    return formatter
}()

public class JudoInterpreter: ExpressionVisitor, StatementVisitor {

    /// global variables
    private let globalVariables: [JudoExpressionVariable]
    private let globalFunctions: [JudoExpressionFunction]

    public init(variables: [JudoExpressionVariable] = [], functions: [JudoExpressionFunction] = []) {
        self.globalVariables = variables
        self.globalFunctions = standardLibrary + functions
    }

    public func interpret(_ source: String) throws -> Any? {
        let parser = Parser(Scanner(source).scan())
        let statements = try parser.parse()
        return try interpret(statements)
    }

    private func interpret(_ statements: [any Statement]) throws -> Any? {
        if statements.count == 1 {
            return try execute(statements[0])
        }

        // run multiple statements and discard returned value
        for stmt in statements {
            _ = try execute(stmt)
        }

        return nil
    }

    private func execute(_ stmt: any Statement) throws -> Any? {
        try stmt.accept(self)
    }

    private func evaluate(_ expr: any Expression) throws -> Any? {
        try expr.accept(self)
    }

    package func visitExpressinStmt(_ stmt: ExpressionStatement) throws -> Any? {
        try evaluate(stmt.expression)
    }

    package func visitCallExpr(_ expr: Call) throws -> Any? {
        let callee = try evaluate(expr.callee)
        let arguments = try expr.arguments.map({ try evaluate($0) })

        if let function = callee as? any Callable {
            return try function.call(self, caller: nil, arguments)
        }

        throw RuntimeError(operator: .identifier(""), message: "Unknown function \(expr.callee)")
    }

    package func visitMethodExpr(_ expr: CallMethod) throws -> Any? {
        let caller = try evaluate(expr.caller)
        let methodName = expr.name
        guard let function = globalFunctions[methodName] else {
            throw RuntimeError(operator: .identifier(""), message: "Unknown function \(methodName)")
        }

        /// Call function with callee instance as caller
        /// Wrap original function in a function (method) that
        /// set instance (caller) as a caller
        return JudoExpressionFunction(methodName) { _, arguments in
            try function.call(self, caller: caller, arguments)
        }
    }

    package func visitIdentifierExpr(_ expr: Identifier) throws -> Any? {
        guard case .identifier(let identifier) = expr.identifier else {
            return nil
        }

        // substitute variable/function/method for identifiers

        if let variable = globalVariables[identifier] {
            return variable
        }

        if let function = globalFunctions[identifier] {
            return function
        }

        return nil
    }

    package func visitLiteralNumberExpr(_ expr: LiteralNumber) throws -> Any? {
        expr.literal
    }

    package func visitLiteralStringExpr(_ expr: LiteralString) throws -> Any? {
        expr.literal
    }

    package func visitLiteralStringInterpolationExpr(_ expr: LiteralStringInterpolation) throws -> Any? {
        let result = try evaluate(expr.expression)

        switch result {
        case let string as String:
            return string
        case let number as Double:
            return numberFormatter.string(from: number as NSNumber)
        case .some(let value):
            return "\(value)"
        default:
            return result
        }
    }

    package func visitLiteralNilExpr(_ expr: LiteralNil) throws -> Any? {
        nil
    }

    package func visitLiteralBoolExpr(_ expr: LiteralBool) throws -> Any? {
        expr.literal
    }

    package func visitGroupingExpr(_ expr: Grouping) throws -> Any? {
        try evaluate(expr.expression)
    }

    package func visitUnaryExpr(_ expr: Unary) throws -> Any? {
        let right = try evaluate(expr.right)

        switch expr.operator.kind {
        case .minus:
            try assertNumber(operator: .minus, right)
            return -(right as! Double)
        case .bang:
            if let bool = right as? Bool {
                return !bool
            } else if right == nil {
                return false
            } else {
                return true
            }
        default:
            break
        }
        return nil
    }

    package func visitBinaryExpr(_ expr: Binary) throws -> Any? {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)

        switch expr.operator.kind {
        case .minus:
            try assertNumber(operator: .minus, left, right)
            return (left as! Double) - (right as! Double)
        case .slash:
            try assertNumber(operator: .slash, left, right)
            if let lhs = left as? Double, let rhs = right as? Double {
                if rhs.isZero {
                    throw RuntimeError(operator: .slash, message: "Disivion by 0")
                }
                return lhs / rhs
            }
        case .star:
            try assertNumber(operator: .star, left, right)
            return (left as! Double) * (right as! Double)
        case .plus:
            // Casting number to string
            switch (left, right) {
            case (let left as String, let right as String):
                return left + right
            case (let left as Double, let right as String):
                return (numberFormatter.string(from: left as NSNumber) ?? "") + right
            case (let left as String, let right as Double):
                return left + (numberFormatter.string(from: right as NSNumber) ?? "")
            default:
                try assertNumber(operator: .plus, left, right)
                return (left as! Double) + (right as! Double)
            }
        case .greater:
            try assertNumber(operator: .greater, left, right)
            return (left as! Double) > (right as! Double)
        case .greaterEqual:
            try assertNumber(operator: .greaterEqual, left, right)
            return (left as! Double) >= (right as! Double)
        case .less:
            try assertNumber(operator: .less, left, right)
            return (left as! Double) < (right as! Double)
        case .lessEqual:
            try assertNumber(operator: .lessEqual, left, right)
            return (left as! Double) <= (right as! Double)
        case .bangEqual:
            if left == nil, right == nil {
                return false
            }

            if left == nil {
                return true
            }

            if let lhs = left as? any Equatable, let rhs = right as? any Equatable {
                return !lhs.isEqual(rhs)
            }
        case .equalEqual:
            if left == nil, right == nil {
                return true
            }

            if left == nil {
                return false
            }

            if let lhs = left as? any Equatable, let rhs = right as? any Equatable {
                return lhs.isEqual(rhs)
            }
        default:
            break
        }

        return nil
    }
}

private func assertNumber(operator: Token.Kind, _ values: Any?...) throws {
    let result = values.allSatisfy { $0 is Double }
    if !result {
        throw RuntimeError(operator: `operator`, message: "Operands must be numbers")
    }
}

private struct RuntimeError: Swift.Error, LocalizedError {
    let `operator`: Token.Kind
    let message: String

    var errorDescription: String? {
        "\(`operator`) \(message)"
    }
}


private extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return other.isExactlyEqual(self)
        }
        return self == other
    }

    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

private extension Array<JudoExpressionVariable> {
    subscript<S: StringProtocol>(_ identifier: S) -> Any? {
        first(where: { $0.identifier == identifier })?.value
    }
}

private extension Array<JudoExpressionFunction> {
    subscript<S: StringProtocol>(_ identifier: S) -> Element? {
        first(where: { $0.selector == identifier })
    }
}
