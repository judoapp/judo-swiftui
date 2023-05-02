public protocol Asset: Codable {
    var sortingIndex: Double? { get }
}

public extension Asset {
    var sortingIndex: Double? {
        0
    }
}
