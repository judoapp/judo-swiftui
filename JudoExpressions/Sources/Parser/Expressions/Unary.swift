import Lexer

package struct Unary: Expression {
    package let `operator`: Token
    package let right: any Expression

    init(`operator`: Token, right: any Expression) {
        self.operator = `operator`
        self.right = right
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitUnaryExpr(self)
    }
}
