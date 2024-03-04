import Foundation
import Lexer

package class Parser {

    /// Scanned tokens
    private let tokens: [Token]

    /// token index
    private var current: Int = 0

    package init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    /// Parse tokens
    package func parse() throws -> [any Statement] {
        var statements: [any Statement] = []
        while !isAtEnd {
            statements.append(try statement())
        }
        return statements
    }

    private func statement() throws -> any Statement {
        // known statement

        // fallback to expression
        try expressionStatement()
    }

    private func expressionStatement() throws -> any Statement {
        let expr = try expression()
        //try consume(.semicolon, message: "Expected ';' after expression")
        return ExpressionStatement(expression: expr)
    }

    private func expression() throws -> any Expression {
        try equality()
    }

    private func equality() throws -> any Expression {
        var expr = try comparison()
        while match(.bangEqual) || match(.equalEqual) {
            let `operator` = previous
            let right = try comparison()
            expr = Binary(left: expr, operator: `operator`, right: right)
        }
        return expr
    }

    private func comparison() throws -> any Expression {
        var expr = try term()

        while match(.greater) || match(.greaterEqual) || match(.less) || match(.lessEqual) {
            let `operator` = previous
            let right = try term()
            expr = Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func term() throws -> any Expression {
        var expr = try factor()

        while match(.minus) || match(.plus) {
            let `operator` = previous
            let right = try factor()
            expr = Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func factor() throws -> any Expression {
        var expr = try unary()

        while match(.slash) || match(.star) {
            let `operator` = previous
            let right = try unary()
            expr = Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func unary() throws -> any Expression {
        if match(.bang) || match(.minus) {
            let `operator` = previous
            let right = try unary()
            return Unary(operator: `operator`, right: right)
        }

        return try call()
    }

    private func call() throws -> any Expression {
        var expr = try primary()

        while true {
            if match(.bracket(.round(.left))) {
                expr = try finishCall(callee: expr, caller: nil)
            } else if match(.dot) {
                let identifier = try consume(.identifier("dummy"), message: "Expect property name after '.'")
                expr = CallMethod(caller: expr, name: identifier.lexeme)
            } else {
                break
            }
        }

        return expr
    }

    private func finishCall(callee: any Expression, caller: (any Expression)?) throws -> any Expression {
        var arguments: [any Expression] = []
        if !check(.bracket(.round(.right))) {
            repeat {
                let expr = try expression()
                arguments.append(expr)
            } while match(.comma)
        }

        try consume(.bracket(.round(.right)), message: "Expect ')' after arguments")
        return Call(callee: callee, caller: caller, arguments: arguments)
    }

    private func grouping() throws -> any Expression {
        let expr = try expression()
        try consume(.bracket(.round(.right)), message: "Expect ')' after expression.")
        return Grouping(expression: expr)
    }

    private func literalNumber() throws -> any Expression {
        guard case .literal(.number(let value)) = previous.kind else {
            throw ParseError(peek, "expected number")
        }

        return LiteralNumber(value)
    }

    private func literalString() throws -> any Expression {
        guard case .literal(.string(.start)) = previous.kind else {
            throw ParseError(peek, "expected string")
        }

        var expr: (any Expression)?
        repeat {
            if case .literal(.string(.plaintext(let plaintext))) = peek.kind {
                advance()

                if let prevExpr = expr {
                    expr = Binary(left: prevExpr, operator: Token(lexeme: "+", kind: .plus), right: LiteralString(plaintext))
                } else {
                    expr = LiteralString(plaintext)
                }
            }

            if case .literal(.string(.interpolationStart)) = peek.kind {
                advance()

                while !match(.literal(.string(.interpolationEnd))) {
                    if let prevExpr = expr {
                        expr = try Binary(left: prevExpr, operator: Token(lexeme: "+", kind: .plus), right: LiteralStringInterpolation(expression: expression()))
                    } else {
                        expr = try LiteralStringInterpolation(expression: expression())
                    }
                }
            }

        } while !match(.literal(.string(.end))) && !isAtEnd

        guard let expr else {
            throw ParseError(peek, "expected text or expression")
        }
        
        return expr
    }

    private func literalTrue() throws -> any Expression {
        guard case .literal(.true) = previous.kind else {
            throw ParseError(peek, "expected boolean")
        }

        return LiteralBool(true)
    }

    private func literalFalse() throws -> any Expression {
        guard case .literal(.false) = previous.kind else {
            throw ParseError(peek, "expected boolean")
        }

        return LiteralBool(false)
    }

    private func identifier() throws -> any Expression {
        guard case .identifier(let identifier) = previous.kind else {
            throw ParseError(peek, "expected identifier")
        }

        return Identifier(.identifier(identifier))
    }

    private func primary() throws -> any Expression {
        if match(.literal(.false)) {
            return try literalFalse()
        } else if match(.literal(.true)) {
            return try literalTrue()
        } else if match(.literal(.nil)) {
            return LiteralNil()
        } else if match(.literal(.string(.start))) {
            return try literalString()
        } else if match(.literal(.dummyNumber)) {
            return try literalNumber()
        } else if match(.bracket(.round(.left))) {
            return try grouping()
        } else if match(.identifier("dummy")) {
            return try identifier()
        }

        throw ParseError(peek, "expected expression")
    }

    private func match(_ kind: Token.Kind) -> Bool {

        while check(.trivia) || check(.whitespace) || check(.newLine) || check(.backslash) {
            advance()
        }

        if check(kind) {
            advance()
            return true
        }

        return false
    }


    private func check(_ kind: Token.Kind) -> Bool {
        if isAtEnd {
            return false
        }

        // for literal compare only kind
        if case .literal(.number) = peek.kind, case .literal(.number) = kind {
            return true
        }

        if case .literal(.string(.plaintext)) = peek.kind, case .literal(.string(.plaintext)) = kind {
            return true
        }

        if case .identifier = peek.kind, case .identifier = kind {
            return true
        }

        return peek.kind == kind
    }

    @discardableResult
    private func consume(_ kind: Token.Kind, message: String) throws -> Token {
        if check(kind) {
            return advance()
        }

        throw ParseError(peek, message)
    }

    @discardableResult
    private func advance() -> Token {
        if !isAtEnd {
            current += 1
        }
        return previous
    }

    private var isAtEnd: Bool {
        peek.kind == .eof
    }

    private var peek: Token {
        tokens[current]
    }

    private var previous: Token {
        tokens[current - 1]
    }

    private func previous(_ n: Int = 1) -> Token {
        tokens[current - n]
    }
}

private struct ParseError: Swift.Error, LocalizedError {
    private let message: String
    private let token: Token

    var errorDescription: String? {
        "'\(token.lexeme)' \(message)"
    }

    init(_ token: Token, _ message: String) {
        self.token = token
        self.message = message
    }
}
