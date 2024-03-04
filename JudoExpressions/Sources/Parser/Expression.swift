package protocol Expression {
    func accept(_ visitor: any ExpressionVisitor) throws -> Any?
}
