package struct ExpressionStatement: Statement {
    package let expression: any Expression

    package func accept(_ visitor: StatementVisitor) throws -> Any? {
        try visitor.visitExpressinStmt(self)
    }
}
