package struct Grouping: Expression  {
    package let expression: any Expression

    init(expression: any Expression) {
        self.expression = expression
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitGroupingExpr(self)
    }
}
