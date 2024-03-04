protocol Callable {
    func call(_ interpreter: Interpreter, caller: Any?, _ args: [Any?]) throws -> Any?
}
