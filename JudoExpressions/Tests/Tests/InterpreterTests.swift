import XCTest
import Lexer
import Parser
import Interpreter

final class InterpreterTests: XCTestCase {

    func testInterpreter() throws {
        let interpreter = Interpreter()
        try XCTAssertEqual(interpreter.interpret("(3 + 3) + (2 * 4)") as? Double, 14.0)
        try XCTAssertEqual(interpreter.interpret("(3 + 3) + (-2 * 4)") as? Double, -2.0)
        try XCTAssertEqual(interpreter.interpret("1") as? Double, 1.0)
        try XCTAssertEqual(interpreter.interpret("-1+1") as? Double, 0.0)
        try XCTAssertEqual(interpreter.interpret("\"$\"+(100/25)") as? String, "$4")
        try XCTAssertEqual(interpreter.interpret("3*2") as? Double, 6.0)
        try XCTAssertEqual(interpreter.interpret("(2 + 8) + (6 / -2)") as? Double, 7.0)
        try XCTAssertEqual(interpreter.interpret("\"a\"") as? String, "a")
        try XCTAssertEqual(interpreter.interpret("\"a\"+\"b\"") as? String, "ab")
        try XCTAssertEqual(interpreter.interpret("\"a\"+1") as? String, "a1")
        try XCTAssertEqual(interpreter.interpret("1+\"a\"") as? String, "1a")
        try XCTAssertEqual(interpreter.interpret("1+\"a\"+1") as? String, "1a1")
        try XCTAssertEqual(interpreter.interpret("1+\"1\"+1") as? String, "111")
        try XCTAssertEqual(interpreter.interpret("!true") as? Bool, false)
        try XCTAssertEqual(interpreter.interpret("true") as? Bool, true)

        try XCTAssertEqual(interpreter.interpret("1 == 2") as? Bool, false)
        try XCTAssertEqual(interpreter.interpret("1 == 1") as? Bool, true)
        try XCTAssertEqual(interpreter.interpret("!(1 == 1)") as? Bool, false)
        try XCTAssertEqual(interpreter.interpret("1 != 5") as? Bool, true)
        try XCTAssertEqual(interpreter.interpret("1 > 3") as? Bool, false)

        try XCTAssertThrowsError(interpreter.interpret("-true"))
        try XCTAssertThrowsError(interpreter.interpret("-\"foo\""))
    }

    func testInterpreterInterpolation() throws {
        let interpreter = Interpreter()
        try XCTAssertEqual(interpreter.interpret("\"1+\\(1 + 2)\"") as? String, "1+3")
        try XCTAssertEqual(interpreter.interpret("\"1\\(1 + 2)\"") as? String, "13")
        try XCTAssertEqual(interpreter.interpret("1+\"1\\(1 + 2)\"") as? String, "113") // "1" + "13"
        try XCTAssertEqual(interpreter.interpret("1+\"\\(1 + 2)\"") as? String, "13")   // "1" + "3"
        try XCTAssertEqual(interpreter.interpret("\"\\(1 + 2)\"") as? String, "3")      // "3"
        try XCTAssertEqual(interpreter.interpret(#""$\(25 / 4)""#) as? String, "$6.25")
        try XCTAssertEqual(interpreter.interpret(#""\((25 / 4))""#) as? String, "6.25")
        try XCTAssertEqual(interpreter.interpret(#""$\(25 / 4)$""#) as? String, "$6.25$")
    }

    func testIdentifier() throws {
        let variables = [
            ExpressionVariable("a", value: 2.0),
            ExpressionVariable("padding", value: 4.0)
        ]

        let interpreter = Interpreter(variables: variables)
        try XCTAssertEqual(interpreter.interpret("2 + a") as? Double, 4.0)
        try XCTAssertEqual(interpreter.interpret("16.0 + padding") as? Double, 20.0)
    }

    func testMethodCall() throws {
        let variables = [
            ExpressionVariable("a", value: 2.0),
            ExpressionVariable("b", value: 5.0),
        ]

        let functions = [

            // Double.increment(Double)
            ExpressionFunction("increment") { caller, arguments in
                guard arguments.count == 1,
                    let value = caller as? Double,
                    let incrementBy = arguments[0] as? Double
                else {
                    // throw runtime error
                    return caller
                }

                return value + incrementBy
            },

            // Double.toString()
            ExpressionFunction("toString") { caller, arguments in
                if let value = caller as? Double {
                    return "\(value)"
                }

                // throw invalid arguments error
                return caller
            },

            // Boolean.toggle()
            ExpressionFunction("toggle") { caller, arguments in
                guard let value = caller as? Bool else {
                    return caller
                }

                return !value
            }
        ]

        let interpreter = Interpreter(
            variables: variables,
            functions: functions
        )

        try XCTAssertEqual(interpreter.interpret("increment(3)") as? Double, nil)

        try XCTAssertEqual(interpreter.interpret("2.increment(3)") as? Double, 5.0)
        try XCTAssertEqual(interpreter.interpret("a.increment((3 + b)) + 1") as? Double, 11.0)
        try XCTAssertEqual(interpreter.interpret("2.toString()") as? String, "2.0")
        try XCTAssertEqual(interpreter.interpret("(1 + a).toString()") as? String, "3.0")
        try XCTAssertEqual(interpreter.interpret("a.increment(1).toString()") as? String, "3.0")
        try XCTAssertEqual(interpreter.interpret("true.toggle()") as? Bool, false)
        try XCTAssertEqual(interpreter.interpret("false.toggle()") as? Bool, true)

        try XCTAssertEqual(
            interpreter.interpret("false.toggle().toggle()") as? Bool,
            false
        )
    }

    func testInterpreterQuote() throws {
        let variables = [
            ExpressionVariable("a", value: 2.0)
        ]
        let interpreter = Interpreter(variables: variables)
        let result = try interpreter.interpret(#""\"foo\(a)bar\"""#) as? String // "\"foo\(a)bar\""
        XCTAssertEqual(result, "\"foo2bar\"")
    }

    func testStringAddInt() throws {
        let variables = [
            ExpressionVariable("a", value: "A"),
            ExpressionVariable("b", value: 1)
        ]
        let interpreter = Interpreter(variables: variables)
        let result = try interpreter.interpret(#"a + b"#) as? String
        XCTAssertEqual(result, #"A1"#)
    }
}



