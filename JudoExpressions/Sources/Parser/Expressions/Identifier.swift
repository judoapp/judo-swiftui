import Lexer

package struct Identifier: Expression {
    package let identifier: Token.Kind

    init(_ identifier: Token.Kind) {
        self.identifier = identifier
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitIdentifierExpr(self)
    }
}
