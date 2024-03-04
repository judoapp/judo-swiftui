import Lexer

/// replace with specialised Literals
package struct LiteralNil: Expression {

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralNilExpr(self)
    }
}

package struct LiteralBool: Expression {
    package let literal: Bool

    init(_ literal: Bool) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralBoolExpr(self)
    }
}

package struct LiteralNumber: Expression {
    package let literal: Double

    init(_ literal: Double) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralNumberExpr(self)
    }
}

package struct LiteralString: Expression {
    package let literal: String

    init(_ literal: String) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralStringExpr(self)
    }
}

package struct LiteralStringInterpolation: Expression {
    package let expression: any Expression

    init(expression: any Expression) {
        self.expression = expression
    }
    
    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralStringInterpolationExpr(self)
    }
}
