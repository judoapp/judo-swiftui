import XCTest
import JudoExpressions

final class LexerTests: XCTestCase {

    func testEmpty() throws {
        let tokens = Scanner("").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testSingleNumberLiteral1() throws {
        let tokens = Scanner("1").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testSingleNumberLiteral2() throws {
        let tokens = Scanner("12.45").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "12.45", kind: .literal(.number(12.45))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testSingleStringLiteral() throws {
        let tokens = Scanner("\"A &&\"").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "A &&", kind: .literal(.string(.plaintext("A &&")))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testExpression() throws {
        let tokens = Scanner("1+2").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testExpressionTrivia() throws {
        let tokens = Scanner("1 + 2").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testExpressionMultiline() throws {
        let tokens = Scanner("1 + 2\n\"A\"  == 3").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: "\n", kind: .newLine),
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "A", kind: .literal(.string(.plaintext("A")))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "==", kind: .equalEqual),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "3", kind: .literal(.number(3))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testIdentifier1() throws {
        let tokens = Scanner("$FOO").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "$FOO", kind: .identifier("$FOO")),
            Token(lexeme: "", kind: .eof)
        ])
    }


    func testIdentifier2() throws {
        let tokens = Scanner("1 + 2\nFOO BAR == true").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: "\n", kind: .newLine),
            Token(lexeme: "FOO", kind: .identifier("FOO")),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "BAR", kind: .identifier("BAR")),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "==", kind: .equalEqual),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "true", kind: .literal(.true)),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testLogicOperator1() throws {
        let tokens = Scanner("1 || 2 && 3").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "||", kind: .or),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "&&", kind: .and),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "3", kind: .literal(.number(3))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testLogicOperator2() throws {
        let tokens = Scanner("1 or 2 and 3").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "or", kind: .or),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "and", kind: .and),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "3", kind: .literal(.number(3))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testLogicOperator3() throws {
        let tokens = Scanner("andrut and organic").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "andrut", kind: .identifier("andrut")),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "and", kind: .and),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "organic", kind: .identifier("organic")),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testObjectOperator1() throws {
        let tokens = Scanner("foo.name").scan()
        XCTAssertEqual(tokens, [
            Token(lexeme: "foo", kind: .identifier("foo")),
            Token(lexeme: ".", kind: .dot),
            Token(lexeme: "name", kind: .identifier("name")),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringEscapedQuote1() throws {
        let tokens = Scanner(#""\"foo\"""#).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: #"""#, kind: .literal(.string(.start))),
            Token(lexeme: #"\"foo\""#, kind: .literal(.string(.plaintext(#""foo""#)))),
            Token(lexeme: #"""#, kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation1() throws {
        let tokens = Scanner("""
        1 + "\\(1 + 2)"
        """).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: "1", kind: .literal(.number(1.0))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "\\(", kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation2() throws {
        let tokens = Scanner("""
        "\\(1 + 2)"
        """).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "\\(", kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation3() throws {
        let tokens = Scanner("""
        "\\(1 + 2) \\(3 + 4)"
        """).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "\\(", kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: " ", kind: .literal(.string(.plaintext(" ")))),
            Token(lexeme: "\\(", kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "3", kind: .literal(.number(3))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "4", kind: .literal(.number(4))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation4() throws {
        let tokens = Scanner("""
        "leading\\(1 + 2)trailing"
        """).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "leading", kind: .literal(.string(.plaintext("leading")))),
            Token(lexeme: #"\("#, kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "1", kind: .literal(.number(1))),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "+", kind: .plus),
            Token(lexeme: " ", kind: .whitespace),
            Token(lexeme: "2", kind: .literal(.number(2))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: "trailing", kind: .literal(.string(.plaintext("trailing")))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation5() throws {
        let tokens = Scanner(#""leading\("1")trailing""#).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "leading", kind: .literal(.string(.plaintext("leading")))),
            Token(lexeme: "\\(", kind: .literal(.string(.interpolationStart))),
            Token(lexeme: "\"", kind: .literal(.string(.start))),
            Token(lexeme: "1", kind: .literal(.string(.plaintext("1")))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: ")", kind: .literal(.string(.interpolationEnd))),
            Token(lexeme: "trailing", kind: .literal(.string(.plaintext("trailing")))),
            Token(lexeme: "\"", kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }

    func testStringInterpolation6() throws {
        let tokens = Scanner(#""\"foo\"""#).scan()

        XCTAssertEqual(tokens, [
            Token(lexeme: #"""#, kind: .literal(.string(.start))),
            Token(lexeme: #"\"foo\""#, kind: .literal(.string(.plaintext(#""foo""#)))),
            Token(lexeme: #"""#, kind: .literal(.string(.end))),
            Token(lexeme: "", kind: .eof)
        ])
    }
}
