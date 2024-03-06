// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
