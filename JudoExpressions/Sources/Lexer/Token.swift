import Foundation

package struct Token: Hashable, CustomDebugStringConvertible {

    package enum Kind: Hashable {

        package enum Literal: Hashable, CustomDebugStringConvertible {

            package enum Segment: Hashable {
                case start  // "
                case end    // "
                case interpolationStart // \(
                case interpolationEnd   // )
                case plaintext(String)
            }

            case string(Segment)
            case number(Double)
            case `true`
            case `false`
            case `nil`

            package static let dummyNumber = Literal.number(0)

            package var debugDescription: String {
                switch self {
                case .string(let value):
                    return "string(\(value))"
                case .number(let value):
                    return "number(\(value))"
                case .true:
                    return "true"
                case .false:
                    return "false"
                case .nil:
                    return "nil"
                }
            }
        }

        package enum Bracket: Hashable {

            public enum Kind: Hashable {
                case left
                case right
            }

            case round(Kind)
            case square(Kind)
            case curly(Kind)
        }

        case bracket(Bracket)

        case comma
        case dot
        case semicolon

        case minus
        case plus
        case slash
        case star

        case bang
        case bangEqual
        case equal
        case equalEqual
        case greater
        case greaterEqual
        case less
        case lessEqual

        case identifier(String)
        case literal(Literal)

        case trivia
        case whitespace
        case newLine

        case backslash

        case and
        case or

        case eof
    }

    package let lexeme: String
    package let kind: Kind

    package init(lexeme: String, kind: Kind) {
        self.lexeme = lexeme
        self.kind = kind
    }

    package var debugDescription: String {
        "\"\(lexeme)\" \(kind)"
    }
}
