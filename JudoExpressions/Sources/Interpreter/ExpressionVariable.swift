public struct ExpressionVariable {
    public let identifier: String
    let value: Any?

    public init(_ identifier: String, value: String?) {
        self.identifier = identifier
        self.value = value
    }

    public init(_ identifier: String, value: Double?) {
        self.identifier = identifier
        self.value = value
    }

    public init(_ identifier: String, value: Int?) {
        self.identifier = identifier
        self.value = value != nil ? Double(value!) : nil
    }

    public init(_ identifier: String, value: Bool) {
        self.identifier = identifier
        self.value = value
    }
}
