import XCTest
import Lexer
import Parser

final class ParserTests: XCTestCase {

    func testParser1() throws {
        let tokens = Scanner("1 + 2").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser2() throws {
        let tokens = Scanner("(1 + 2) * 3").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser3() throws {
        let tokens = Scanner("2 == (3 + 1)").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser4() throws {
        let tokens = Scanner("\"text\"").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser5() throws {
        let tokens = Scanner("\"\\(1 + 2)\"").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser6() throws {
        let tokens = Scanner("\"text\\(1 + 2)\"").scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }

    func testParser7() throws {
        let tokens = Scanner(#""leading\("1" + 2)trailing""#).scan()
        let parser = Parser(tokens)
        XCTAssertNoThrow(try parser.parse())
    }
}
