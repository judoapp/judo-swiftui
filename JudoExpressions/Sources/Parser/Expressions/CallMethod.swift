import Lexer

package struct CallMethod: Expression {
    package let caller: any Expression
    package let name: String

    init(caller: any Expression, name: String) {
        self.caller = caller
        self.name = name
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitMethodExpr(self)
    }

}
