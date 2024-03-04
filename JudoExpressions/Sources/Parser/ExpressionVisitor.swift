package protocol ExpressionVisitor {
    func visitCallExpr(_ expr: Call) throws -> Any?
    func visitMethodExpr(_ expr: CallMethod) throws -> Any?
    func visitIdentifierExpr(_ expr: Identifier) throws -> Any?
    func visitLiteralStringExpr(_ expr: LiteralString) throws -> Any?
    func visitLiteralStringInterpolationExpr(_ expr: LiteralStringInterpolation) throws -> Any?
    func visitLiteralNumberExpr(_ expr: LiteralNumber) throws -> Any?
    func visitLiteralBoolExpr(_ expr: LiteralBool) throws -> Any?
    func visitLiteralNilExpr(_ expr: LiteralNil) throws -> Any?
    func visitGroupingExpr(_ expr: Grouping) throws -> Any?
    func visitUnaryExpr(_ expr: Unary) throws -> Any?
    func visitBinaryExpr(_ expr: Binary) throws -> Any?
}
