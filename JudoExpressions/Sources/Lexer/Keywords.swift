import Foundation

enum Keyword: String, CaseIterable {
    case `true`
    case `false`
    case `nil`
    case and
    case or

    var tokenKind: Token.Kind {
        switch self {
        case .true:
            return .literal(.true)
        case .false:
            return .literal(.false)
        case .nil:
            return .literal(.nil)
        case .and:
            return .and
        case .or:
            return .or
        }
    }
}
