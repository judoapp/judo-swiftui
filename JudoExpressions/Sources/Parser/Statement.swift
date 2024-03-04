package protocol Statement {
    func accept(_ visitor: any StatementVisitor) throws -> Any?
}
