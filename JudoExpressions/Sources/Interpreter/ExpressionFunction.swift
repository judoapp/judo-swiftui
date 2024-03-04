public struct ExpressionFunction: Callable {
    let selector: String
    let closure: (_ caller: Any?, _ arguments: [Any?]) throws -> Any?

    public init(_ selector: String, closure: @escaping (_ caller: Any?, _ arguments: [Any?]) throws -> Any?) {
        self.selector = selector
        self.closure = closure
    }

    func call(_ interpreter: Interpreter, caller: Any?, _ args: [Any?]) throws -> Any? {
        try closure(caller, args)
    }
}
