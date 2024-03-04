import Lexer

package struct Call: Expression {
    package let callee: any Expression
    package let caller: (any Expression)?
    package let arguments: [any Expression]

    init(callee: any Expression, caller: (any Expression)?, arguments: [any Expression]) {
        self.callee = callee
        self.caller = caller
        self.arguments = arguments
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitCallExpr(self)
    }
}
