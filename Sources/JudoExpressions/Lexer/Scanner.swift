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
import OSLog

private let logger = Logger()

package class Scanner {
    private let source: String
    package private(set) var tokens: [Token] = []

    private var startIndex: String.Index
    private var currentIndex: String.Index

    package init(_ source: String) {
        self.source = source
        self.startIndex = source.startIndex
        self.currentIndex = source.startIndex
    }

    package func scan() -> [Token] {

        while !isAtEnd {
            startIndex = currentIndex
            scanToken()
        }

        tokens.append(Token(lexeme: "", kind: .eof))
        return tokens
    }


    private var isAtEnd: Bool {
        currentIndex >= source.endIndex
    }

    /// Consume character
    @discardableResult
    private func advance() -> Character {
        let c = source[currentIndex]
        currentIndex = source.index(after: currentIndex)
        return c
    }

    private func match(_ expected: Character) -> Bool {
        if isAtEnd {
            return false
        }

        if source[currentIndex] != expected {
            return false
        }

        currentIndex = source.index(after: currentIndex)
        return true
    }

    private var peek: Character? {
        if isAtEnd {
            return nil
        }
        return source[currentIndex]
    }

    private var peekNext: Character? {
        if isAtEnd {
            return nil
        }

        let nextIndex = source.index(after: currentIndex)
        if nextIndex >= source.endIndex {
            return nil
        }

        return source[nextIndex]
    }

    private var peekPrev: Character? {
        if isAtEnd {
            return nil
        }

        let prevIndex = source.index(before: currentIndex)
        if prevIndex < source.startIndex {
            return nil
        }

        return source[prevIndex]
    }

    private func addToken(_ kind: Token.Kind) {
        let lexeme = String(source[startIndex..<currentIndex])
        tokens.append(Token(lexeme: lexeme, kind: kind))
    }

    private func string() {
        addToken(.literal(.string(.start)))
        startIndex = currentIndex

        while !isAtEnd {

            if peek == #"""# && peekPrev != #"\"# {
                break
            }

            if peek == #"\"#, peekNext == "(" {
                // register leading plaintext
                if startIndex != currentIndex {
                    let plaintext = String(source[startIndex..<currentIndex]).replacingOccurrences(of: "\\\"", with: "\"")
                    addToken(.literal(.string(.plaintext(plaintext))))
                    startIndex = currentIndex
                }

                // \(
                advance()
                advance()

                addToken(.literal(.string(.interpolationStart)))

                var parenCount = 0
                while !isAtEnd {
                    if peek == "(" {
                        parenCount += 1
                    }

                    if peek == ")" {
                        parenCount -= 1
                    }

                    startIndex = currentIndex
                    scanToken()

                    if parenCount == 0 && peek == ")" {
                        break
                    }
                }

                if isAtEnd {
                    if startIndex != currentIndex {
                        // not closed string literal is not a string literal
                        addToken(.trivia)
                    }
                    return
                }

                startIndex = currentIndex
                advance()

                addToken(.literal(.string(.interpolationEnd)))
                startIndex = currentIndex
            } else if peek == #"\"#, peekNext == #"""# {
                advance()
            } else if !isAtEnd {
                advance()
            }

        }

        if isAtEnd {
            if startIndex != currentIndex {
                // not closed string literal is not a string literal
                addToken(.trivia)
            }
            return
        }

        // register plaintext
        if startIndex != currentIndex {
            // remove escaped quotation from literal (not from lexeme)
            // \" -> "
            let plaintext = String(source[startIndex..<currentIndex]).replacingOccurrences(of: "\\\"", with: "\"")
            addToken(.literal(.string(.plaintext(plaintext))))
            startIndex = currentIndex
        }

        advance() // "
        addToken(.literal(.string(.end)))
    }

    private func number() {
        while let c = peek, c.isNumber == true {
            advance()
        }

        // look for a fractional part.
        if let c = peek, c == ".", let cc = peekNext, cc.isNumber { // TODO: use locale
            // consume "."
            advance()

            while let c = peek, c.isNumber {
                advance()
            }
        }

        let value = String(source[startIndex..<currentIndex])
        if let double = Double(value) {
            addToken(.literal(.number(double)))
        }
    }

    private func identifier() {
        while let c = peek, c.isAlphaNumeric {
            advance()
        }

        let identifier = String(source[startIndex..<currentIndex])
        if let keyword = Keyword.allCases.first(where: { $0.rawValue == identifier }) {
            addToken(keyword.tokenKind)
        } else {
            addToken(.identifier(identifier))
        }
    }

    @discardableResult
    private func scanToken() -> Character {
        let c = advance()
        switch c {
        case "(":
            addToken(.bracket(.round(.left)))
        case ")":
            addToken(.bracket(.round(.right)))
        case "[":
            addToken(.bracket(.square(.left)))
        case "]":
            addToken(.bracket(.square(.right)))
        case "{":
            addToken(.bracket(.curly(.left)))
        case "}":
            addToken(.bracket(.curly(.right)))
        case ",":
            addToken(.comma)
        case ".":
            addToken(.dot)
        case "-":
            addToken(.minus)
        case "+":
            addToken(.plus)
        case ";":
            addToken(.semicolon)
        case "*":
            addToken(.star)
        case "!":
            addToken(match("=") ? .bangEqual : .bang)
        case "=":
            addToken(match("=") ? .equalEqual : .equal)
        case "<":
            addToken(match("=") ? .lessEqual : .less)
        case ">":
            addToken(match("=") ? .greaterEqual : .greater)
        case #"\"#:
            addToken(.backslash)
        case "&" where peek == "&":
            advance()
            addToken(.and)
        case "|" where peek == "|":
            advance()
            addToken(.or)
        case "/":
            if match("/") {
                // comment
                while let ch = peek, !ch.isNewline, !isAtEnd {
                    advance()
                }
            } else {
                addToken(.slash)
            }
        case let c where c.isWhitespace:
            if c.isNewline {
                addToken(.newLine)
            } else {
                addToken(.whitespace)
            }
        case "$":
            identifier()
        case #"""#:
            string()
        case let c where c.isNumber:
            number()
        case let c where c.isAlpha:
            identifier()
        default:
            addToken(.trivia)
            logger.warning("Unexpected character \"\(c)\".")
        }

        return c
    }

}


private extension Character {
    var isAlpha: Bool {
        isLetter || self == "_" || self == "\u{B7}"
    }

    var isAlphaNumeric: Bool {
        isAlpha || isNumber
    }
}
