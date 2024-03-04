import Lexer

package struct Binary: Expression {
    package let left: any Expression
    package let `operator`: Token
    package let right: any Expression

    package init(left: any Expression, `operator`: Token, right: any Expression) {
        self.left = left
        self.operator = `operator`
        self.right = right
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitBinaryExpr(self)
    }
}
