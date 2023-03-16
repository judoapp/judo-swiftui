@testable import JudoModelV2
import XCTest

class StringInterpolationTests: XCTestCase {


    // MARK: - No Interpolation
    func test_evaluatingExpressions_withNoInterpolation_returnsOriginalString() throws {
        let sut = try makeSUT(nonInterpolatedString())
        XCTAssertEqual(sut, nonInterpolatedString())
    }

    func test_evaluatingExpressions_givenDataURLParametersUserInfoComponentPropertiesAndNoInterpolation_returnsOriginalString() throws {
        let data = ["page":2]
        let properties = try constructComponentProperties(with: ["name": "John"])

        let sut = try makeSUT(nonInterpolatedString(), data: data, properties: properties)
        XCTAssertEqual(sut, nonInterpolatedString())
    }

    func test_evaluatingExpressions_incompleteInterpolation_returnsOriginalString() throws {
        let properties = try constructComponentProperties(with: ["userid": "54321"])

        let sut = try makeSUT("{{properties.userid", properties: properties)
        XCTAssertEqual(sut, "{{properties.userid")
    }

    // MARK: - Throwing
    func test_evalutingExpression_withInterpolatingNoUserInfo_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{user.userID}}", expectedError: unexpectedValueError())
    }

    func test_evalutingExpression_withInterpolatingNoURLParameters_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{url.page}}", expectedError: unexpectedValueError())
    }

    func test_evaluatingExpressions_withInterpolatingNoData_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{data.count}}", expectedError: unexpectedValueError())
    }

    func test_evaluatingExpressions_incorrectInterpolationWithTwoValues_throwsError() throws {
        let properties = try constructComponentProperties(with: ["userid": "54321", "name": "mike"])
        let expectedError = StringExpressionError("Invalid expression \"properties.userid properties.name\"")
        throwsErrorWhenUnableToInterpolate("{{properties.userid properties.name}}", properties: properties, expectedError: expectedError)
    }

    // MARK: - Straight Interpolation (no helpers)
    func test_evaluatingExpressions_withInterpolationForUserInfo_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["name":"George"])

        let sut = try makeSUT("{{properties.name}}", properties: properties)
        XCTAssertEqual(sut, "George")
    }

    func test_evaluatingExpressions_withInterpolationForURLParameters_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["page":"three"])

        let sut = try makeSUT("{{properties.page}}", properties: properties)
        XCTAssertEqual(sut, "three")
    }

    func test_evaluatingExpressions_withInterpolationForData_returnsExpectedString() throws {

        let sut = try makeSUT("{{data.age}}", data: ["age":"Twenty"])
        XCTAssertEqual(sut, "Twenty")
    }

    func test_evaluatingExpressions_withInterpolationForComponentProperties_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["name": "Mike"])

        let sut = try makeSUT("{{properties.name}}", properties: properties)
        XCTAssertEqual(sut, "Mike")
    }

    func test_evaluatingExpressions_withMultipleInterpolations_returnsExpectedString() throws {
        let data = ["page": 2]
        let properties = try constructComponentProperties(with: ["key2": "value2", "userid": "54321"])

        let string = "{{data.page}} {{properties.key2}} {{properties.userid}}"

        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "2 value2 54321")
    }

    func test_evaluatingExpressions_dataWithDifferentNumberTypes_returnsExpectedString() throws {
        let data = ["int": 2, "negInt": -4, "double": 2.34, "negDouble": -55.7]
        let string = "{{data.int}} {{data.negInt}} {{data.double}} {{data.negDouble}}"

        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "2 -4 2 -56")
    }

    // MARK: - Lowercase helper
    func test_evaluatingExpressions_lowercaseString_returnsExpectedString() throws {
        let sut = try makeSUT("{{lowercase \"UPPERCASED\"}}")
        XCTAssertEqual(sut, "uppercased")
    }

    func test_evaluatingExpressions_lowercase_returnsExpectedString() throws {
        let data = ["name": "AN UPPERCASE NAME"]
        let string = "{{lowercase data.name}}"

        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "an uppercase name")
    }

    func test_evaluatingExpressions_lowercase_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("lowercase", expectedArguments: 2)
    }

    // MARK: - Uppercase helper
    func test_evaluatingExpressions_uppercaseString_returnsExpectedString() throws {
        let sut = try makeSUT("{{uppercase \"lowercased\"}}")
        XCTAssertEqual(sut, "LOWERCASED")
    }

    func test_evaluatingExpressions_uppercase_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["info": "a lowercase name"])
        let string = "{{uppercase properties.info}}"

        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "A LOWERCASE NAME")
    }

    func test_evaluatingExpressions_uppercase_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("uppercase", expectedArguments: 2)
    }

    // MARK: - Replace helper
    func test_evaluatingExpressions_replaceString_returnsExpectedString() throws {
        let sut = try makeSUT("{{replace \"lowercased\" \"lower\" \"upper\"}}")
        XCTAssertEqual(sut, "uppercased")
    }

    func test_evaluatingExpression_replaceMultipleWords_returnsExpectedString() throws {
        let sut = try makeSUT("{{replace \"jack be nimble\" \"be nimble\" \"is amazing\"}}")
        XCTAssertEqual(sut, "jack is amazing")
    }

    func test_evaluatingExpressions_replaces_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["message": "You should be good"])

        let string = "{{replace properties.message \"should\" \"must\"}}"

        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "You must be good")
    }

    func test_evaluatingExpressions_replace_notInString_returnsInitialString() throws {
        let data = ["name": "mike"]

        let sut = try makeSUT("{{replace data.name \"M\" \"P\"}}", data: data)
        XCTAssertEqual(sut, "mike")
    }

    func test_evaluatingExpressions_replace_thirdArgumentWithoutQuotes_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{replace \"lowercased\" lower \"upper\"}}", expectedError: .invalidReplaceArguments)
    }

    func test_evaluatingExpressions_replace_fourthArgumentWithoutQuotes_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{replace \"a fox runs\" \"fox\" dog}}", expectedError: .invalidReplaceArguments)
    }

    func test_evaluatingExpressions_replace_ThirdFourthArgumentsWithoutQuotes_throwsError() throws {
        throwsErrorWhenUnableToInterpolate("{{replace \"a fox runs\" fox dog}}", expectedError: .invalidReplaceArguments)
    }

    func test_evaluatingExpressions_replace_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("replace", expectedArguments: 4)
    }

    func test_evaluatingExpressions_replace_compound_returnsExpectString() throws {
        let sut = try makeSUT("{{ replace (dropLast (dropFirst \"mr. jack reacher\" 4) 8) \"jack\" \"mike\" }}")
        XCTAssertEqual(sut, "mike")
    }

    // MARK: - DateFormat helper
    func test_evaluatingExpressions_dateString_returnsExpectedString() throws {
        let sut = try makeSUT("{{dateFormat \"2022-02-01 19:46:31+0000\" \"EEEE, d\"}}")
        XCTAssertEqual(sut, "Tuesday, 1")
    }

    func test_evaluatingExpressions_dateFormat_returnsExpectedString() throws {
        let data = ["date": "2022-02-01T19:46:31+0000"]
        let properties = try constructComponentProperties(with: ["time": "2022-02-01 19:46:31+0000", "day": "2022-02-01 19:46:31+0000"])

        let string = "{{dateFormat data.date \"yyyy-MM-dd\"}}, {{dateFormat properties.time \"HH:mm:ss\"}}. {{dateFormat properties.day \"EEEE, MMM d, yyyy\"}}"

        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "2022-02-01, 19:46:31. Tuesday, Feb 1, 2022")
    }

    // Added to cover the legacy usecase of date. This test should be removed once we stop
    // supporting the helper date and move to dateFormat exclusively.
    func test_evaluatingExpressions_date_returnsExpectedString() throws {
        let data = ["date": "2022-02-01T19:46:31+0000"]
        let properties = try constructComponentProperties(with: ["time": "2022-02-01 19:46:31+0000", "day": "2022-02-01 19:46:31+0000"])

        let string = "{{date data.date \"yyyy-MM-dd\"}}, {{date properties.time \"HH:mm:ss\"}}. {{date properties.day \"EEEE, MMM d, yyyy\"}}"

        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "2022-02-01, 19:46:31. Tuesday, Feb 1, 2022")
    }

    func test_evaluatingExpressions_dateFormat_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("dateFormat", expectedArguments: 3)
    }

    func test_evaluatingExpressions_dateFormat_throwsError() throws {
        let data = ["date": "NOT A DATE!"]
        throwsErrorWhenUnableToInterpolate("{{dateFormat data.date yyyy-MM-dd}}", data: data, expectedError: .invalidDate)
    }

    func test_evaluatingExpressions_dateFormat_invalidDateFormat_throwsError() throws {
        let data = ["date" : "2022-02-01T19:46:31+0000"]
        throwsErrorWhenUnableToInterpolate("{{dateFormat data.date yyyy-MM}}", data: data, expectedError: .invalidDateFormatPassed)
    }

    // MARK: - DropsFirst helper
    func test_evaluatingExpressions_dropFirstString_returnsExpectedString() throws {
        let sut = try makeSUT("{{dropFirst \"Boom! Kapow!\" 6}}")
        XCTAssertEqual(sut, "Kapow!")
    }

    func test_evaluatingExpressions_dropFirst_returnsExpectedString() throws {
        let data = ["name": "Mr. Hulk Hogan"]
        let string = "{{dropFirst data.name 4}}"

        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "Hulk Hogan")
    }

    func test_evaluatingExpressions_dropFirst_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("dropFirst", expectedArguments: 3)
    }

    func test_evaluatingExpressions_dropFirst_nonInteger_throwsError() throws {
        throwsErrorWhenAnIntegerArgumentIsMissing("dropFirst")
    }

    // MARK: - DropsLast helper
    func test_evaluatingExpressions_dropLastString_returnsExpectedString() throws {
        let sut = try makeSUT("{{dropLast \"Boom! Kapow!\" 7}}")
        XCTAssertEqual(sut, "Boom!")
    }

    func test_evaluatingExpressions_dropLast_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["alphabet": "abcdefghijklmnopqrstuvwxyz"])
        let string = "{{dropLast properties.alphabet 20}}"

        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "abcdef")
    }

    func test_evaluatingExpressions_dropLast_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("dropLast", expectedArguments: 3)
    }

    func test_evaluatingExpressions_dropLast_nonInteger_throwsError() throws {
        throwsErrorWhenAnIntegerArgumentIsMissing("dropLast")
    }

    // MARK: - Prefix helper
    func test_evaluatingExpressions_prefixString_returnsExpectedString() throws {
        let sut = try makeSUT("{{prefix \"Stand by me!\" 8}}")
        XCTAssertEqual(sut, "Stand by")
    }

    func test_evaluatingExpressions_prefix_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["title":"Welcome to the jungle"])
        let string = "{{prefix properties.title 7}}"

        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "Welcome")
    }

    func test_evaluatingExpressions_prefix_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("prefix", expectedArguments: 3)
    }

    func test_evaluatingExpressions_prefix_nonInteger_throwsError() throws {
        throwsErrorWhenAnIntegerArgumentIsMissing("prefix")
    }

    // MARK: - Suffix helper
    func test_evaluatingExpressions_suffixString_returnsExpectedString() throws {
        let sut = try makeSUT("{{suffix \"Boom! Kapow!\" 6}}")
        XCTAssertEqual(sut, "Kapow!")
    }

    func test_evaluatingExpressions_suffix_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["alphabet": "abcdefghijklmnopqrstuvwxyz"])
        let string = "{{suffix properties.alphabet 4}}"

        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "wxyz")
    }

    func test_evaluatingExpressions_suffix_invalidNumberOfArguments_throwsError() throws {
        throwsErrorWithIncorrectNumberOfArguments("suffix", expectedArguments: 3)
    }

    func test_evaluatingExpressions_suffix_nonInteger_throwsError() throws {
        throwsErrorWhenAnIntegerArgumentIsMissing("suffix")
    }

    // MARK: - Nested helpers
    func test_exvaluationExpression_nestedHelpersString_returnsExpecteString() throws {
        let string = "{{ uppercase (suffix (dropFirst \"mr. jack reacher\" 4) 7) }}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "REACHER")
    }

    func test_evaluatingExpressions_nestedHelpersMultiple_returnsExpectedString() throws {
        let data = ["name": "MR. JONATHON", "message": "Show me the way to go home!"]
        let string = "{{ lowercase (prefix (dropFirst data.name 4) 3) }} {{uppercase (dropLast data.message 6)}}"

        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "jon SHOW ME THE WAY TO GO")
    }

    func test_evaluatingExpressions_nestedHelpersMultipleContainsParenthesis_returnsExpectedString() throws {
        let data = ["first": "John Smith (Deceased) 1984"]
        let string = "{{suffix (dropLast (uppercase (dropFirst data.first 5)) 6) 8}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "DECEASED")
    }


    func test_evaluatingExpressions_nestedHelpersMissingClosingParenthesis_throwsError() throws {
        let string = "{{dropFirst (uppercase \"morrison\" 5}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpressions_nestedHelpersMissingOpeningParenthesis_throwsError() throws {
        let string = "{{dropFirst uppercase \"morrison\") 5}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    // MARK: - NumberFormat helper
    func test_evaluatingExpressions_numberFormatStringLiteralNonNumber_throwsError() throws {
        let string = "{{numberFormat \"Twenty\"}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .invalidArgument)
    }

    func test_evaluatingExpressions_numberFormatNonNumber_throwsError() throws {
        let properties = try constructComponentProperties(with: ["average": "NOT A NUMBER"])
        let string = "{{numberFormat properties.average}}"
        throwsErrorWhenUnableToInterpolate(string, properties: properties, expectedError: .invalidArgument)
    }

    func test_evaluatingExpressions_numberFormat_invalidNumberOfArguments_throwsError() throws {
        let invalidStrings = ["{{numberFormat }}", "{{numberFormat extra extra extra}}"]
        for string in invalidStrings {
            throwsErrorWhenUnableToInterpolate(string, expectedError: StringExpressionError("Expected at least 2 arguments"))
        }
    }

    func test_evaluatingExpressions_numberFormatWithStringInt_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["balance": "23"])
        let string = "{{numberFormat properties.balance}}"
        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "23")
    }

    func test_evaluatingExpressions_numberFormatWithStringDouble_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["balance": "23.55"])
        let string = "{{numberFormat properties.balance}}"
        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "23.55")
    }

    func test_evaluatingExpressions_numberFormatWithStringLiteralInt_returnsExpectedString() throws {
        let string = "{{numberFormat \"568\"}}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "568")
    }

    func test_evaluatingExpressions_numberFormatWithStringLiteralDouble_returnsExpectedString() throws {
        let string = "{{numberFormat \"123.456\"}}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "123.456")
    }

    func test_evaluatingExpressions_numberFormatWithInt_returnsExpectedString() throws {
        let data = ["count": 30]
        let string = "{{numberFormat data.count}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "30")
    }

    func test_evaluatingExpressions_numberFormatWithDouble_returnsExpectedString() throws {
        let data = ["average": 12.3487]
        let string = "{{numberFormat data.average}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "12.349")
    }

    func test_evaluatingExpressions_numberFormatNone_returnsExpectedString() throws {
        let data = ["number": 42.5]
        let properties = try constructComponentProperties(with: ["average": "16.8"])
        let string = "{{numberFormat \"0.92\" \"none\"}} {{numberFormat data.number  \"none\"}} {{ numberFormat properties.average  \"none\" }}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "1 42 17")
    }

    func test_evaluatingExpressions_numberFormatDecimal_returnsExpectedString() throws {
        let data = ["number": 42.5]
        let properties = try constructComponentProperties(with: ["average": "16.81145"])
        let string = "{{numberFormat \"0.92\" \"decimal\"}} {{numberFormat data.number \"decimal\"}} {{ numberFormat properties.average \"decimal\" }}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "0.92 42.5 16.811")
    }

    func test_evaluatingExpressions_numberFormatNoStylePassed_returnsExpectedString() throws {
        let data = ["number": 42.5]
        let properties = try constructComponentProperties(with: ["average": "16.81145"])
        let string = "{{numberFormat \"0.92\"}} {{numberFormat data.number}} {{ numberFormat properties.average }}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "0.92 42.5 16.811")
    }

    func test_evaluatingExpressions_numberFormatInvalidStyle_returnsExpectedString() throws {
        let data = ["number": 42.5]
        let properties = try constructComponentProperties(with: ["average": "16.81145"])
        let string = "{{numberFormat \"0.92\" \"gibberish\"}} {{numberFormat data.number \"gibberish\"}} {{ numberFormat properties.average gibberish}}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "0.92 42.5 16.811")
    }

    func test_evaluatingExpression_numberFormatCurrency_returnsExpectedString() throws {
        let data = ["number": 42.5]
        let properties = try constructComponentProperties(with: ["average": "16.81145"])
        let string = "{{numberFormat \"0.92\" \"currency\"}} {{numberFormat data.number \"currency\"}} {{ numberFormat properties.average \"currency\" }}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "$0.92 $42.50 $16.81")
    }

    func test_evaluatingExpressions_numberFormatPercent_returnsExpectedString() throws {
        let data = ["number": 0.348]
        let properties = try constructComponentProperties(with: ["average": "0.1145"])
        let string = "{{numberFormat \"0.92\" \"percent\"}} {{numberFormat data.number \"percent\"}} {{ numberFormat properties.average \"percent\" }}"
        let sut = try makeSUT(string, data: data, properties: properties)
        XCTAssertEqual(sut, "92% 35% 11%")
    }

    func test_evaluatingExpressions_numberFormatWithNestedHelpers_returnsExpectedString() throws {
        let data = ["amount": "UK£123.45pence"]
        let string = "{{numberFormat (dropFirst (dropLast data.amount 5) 3) \"currency\"}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "$123.45")
    }

    func test_evaluatingExpressions_html_returnsExpectedString() throws {
        let data = ["body": "<div style=\"height: 300px\"><p><b>SAN JOSE</b></div>"]
        let string = "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0\"><div style=\"height: 300px\">{{data.body}}</div>"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0\"><div style=\"height: 300px\"><div style=\"height: 300px\"><p><b>SAN JOSE</b></div></div>")
    }

    // MARK: - New Line Specific Tests \n
    func test_evaluatingExpressions_newLineInDataSource_returnsExpectedString() throws {
        let data = ["newLine": "This has a \n in it"]
        let string = "{{data.newLine}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "This has a \n in it")
    }

    func test_evaluatingExpressions_newLineInStringLiteral_returnsExpectedString() throws {
        let string = "{{lowercase \"NEW LINE -> \n <- \"}}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "new line -> \n <- ")
    }

    func test_evaluatingExpressions_unicodeNewLinesInDataSource_returnsExpectedString() throws {
        let data = ["body": "Mac insered new lines \u{2028} \u{2029}"]
        let string = "{{data.body}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "Mac insered new lines \u{2028} \u{2029}")
    }

    func test_evaluatingExpressions_unicodeNewLinesInStringLiteral_returnsExpectedString() throws {
        let string = "{{uppercase \"1st\u{2028}2nd\u{2029}3rd\"}}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "1ST\u{2028}2ND\u{2029}3RD")
    }

    func test_evaluatingExpressions_newLinesMultipleHelpersFromDataSource_returnsExpectedString() throws {
        let data = ["body": "This is the first line\nand the second line"]
        let string = "{{dropFirst (uppercase (replace data.body \"line\" \"sentence\")) 8}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "THE FIRST SENTENCE\nAND THE SECOND SENTENCE")
    }

    // MARK: - Quotation Mark Specific Tests
    func test_evaluatingExpressions_additionalQuotationsRemain_returnsExpectedString() throws {
        let properties = try constructComponentProperties(with: ["username": "\"aperson\""])
        let string = "Username: {{properties.username}}"
        let sut = try makeSUT(string, properties: properties)
        XCTAssertEqual(sut, "Username: \"aperson\"")
    }

    func test_evaluatingExpressions_replace_valueMidSentenceHasSmartQuotes_returnsExpectedString() throws {
        let string = "{{replace \"My name is ‟Mike” smith\" \"Mike\" \"JAMES\"}}"
        let sut = try makeSUT(string)
        XCTAssertEqual(sut, "My name is ‟JAMES” smith")
    }

    func test_evaluatingExpressions_removeFirstQuotationMarksInDataSource_returnsExpectedString() throws {
        let data = ["name": "\"Mike\""]
        let string = "{{dropFirst data.name 1}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "Mike\"")
    }

    func test_evaluatingExpressions_uppercaseWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["message": "Who you going to call? \"Ghostbusters\""]
        let string = "{{uppercase data.message}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "WHO YOU GOING TO CALL? \"GHOSTBUSTERS\"")
    }

    func test_evaluatingExpressions_lowercaseWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["phrase": "I AM \"HE-MAN\"!"]
        let string = "{{lowercase data.phrase}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "i am \"he-man\"!")
    }

    func test_evaluatingExpressions_dropFirstWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["phrase": "I AM \"HE-MAN\"!"]
        let string = "{{dropFirst data.phrase 5}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "\"HE-MAN\"!")
    }

    func test_evaluatingExpressions_dropLastWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["message": "Who you going to call? \"Ghostbusters\""]
        let string = "{{dropLast data.message 15}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "Who you going to call?")
    }

    func test_evaluatingExpressions_prefixWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["sentence": "Ancients spirits of \"evil\""]
        let string = "{{prefix data.sentence 7}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "Ancient")
    }

    func test_evaluatingExpressions_suffixWithQuotesInDataSource_returnsExpectedString() throws {
        let data = ["sentence": "Ancients spirits of \"evil\""]
        let string = "{{suffix data.sentence 6}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "\"evil\"")
    }

    func test_evaluatingExpressions_multipleExpressionsInStringWithQuotationMarks_returnsExpectedString() throws {
        let data = ["firstname": "Sally \"Anne\"", "lastname": "Smith \"(Duck)\""]
        let string = "{{uppercase data.firstname}} {{lowercase data.lastname}}"
        let sut = try makeSUT(string, data: data)
        XCTAssertEqual(sut, "SALLY \"ANNE\" smith \"(duck)\"")
    }

    // MARK: - Failing Quotation Tests
    // The parsing should be updated so that these strings don't throw errors when passed.
    func test_evaluatingExpressions_replaceStringLiteralWithQuotations_throwsError() throws {
        let string = "{{replace \"My name is \"Mike\" smith\" \"Mike\" \"JAMES\"}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(4))
    }

    func test_evaluatingExpressions_uppercaseStringLiteralWithQuotations_throwsError() throws {
        let string = "{{uppercase \"Who you going to call? \"Ghostbusters\"!\"}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(2))
    }

    func test_evaluatingExpressions_lowercaseStringLiteralWithQuotations_throwsError() throws {
        let string = "{{lowercase \"\"MIKE\"\"}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(2))
    }

    func test_evaluatingExpressions_dropFirstStringLiteralWithQuotations_throwsError() throws {
        let string = "{{dropFirst \"My name is \"MIKE\"\" 3}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpression_dropLastStringLiteralWithQuotations_throwsError() throws {
        let string = "{{dropLast \"My name is \"MIKE\" Schultz\" 1}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpression_suffixStringLiteralWithQuotations_throwsError() throws {
        let string = "{{suffix \"My name is \"MIKE\" Schultz\" 7}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpression_prefixStringLiteralWithQuotations_throwsError() throws {
        let string = "{{prefix \"\"MIKE\" Schultz\" 6}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpressions_stringLiteralWithMultipleHelpersWithQuotationMarks_throwsError() throws {
        let string = "{{ uppercase (dropLast (dropFirst \"mr. \"Jack\" reacher\" 4) 8) }}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(3))
    }

    func test_evaluatingExpressions_replaceQuotationMarksInStringLiteral_throwsError() throws {
        let string = "{{replace \"Welcome to the \"jungle\".\" \"\"\" \"::\"}}"
        throwsErrorWhenUnableToInterpolate(string, expectedError: .argumentCount(4))
    }

    // The current implemention means that it is not possible to do a replace on quotation marks
    // that are contained within the data source string. This is a limitation of the current approach.
    func test_evaluatingExpression_replaceQuotationMarksInDataSource_throwsError() throws {
        let data = ["message": "Welcome to the \"jungle\"."]
        let string = "{{replace data.message \"\"\" \"::\"}}"
        throwsErrorWhenUnableToInterpolate(string, data: data, expectedError: .argumentCount(4))
    }

    func test_evaluatingExpressions_multipleHelpersWithQuotationMarksInUserInfo_throwsError() throws {
        let properties = try constructComponentProperties(with: ["fullname":"mr. \"Jack\" reacher"])
        let string = "{{ uppercase (dropLast (dropFirst properties.fullname 4) 8) }}"
        throwsErrorWhenUnableToInterpolate(string, properties: properties, expectedError: .argumentCount(3))
    }

    func test_evelautingExpressions_multipleHelpersWithQuotationMarksInDataSource_throwsError() throws {
        let data = ["name": "\"Mike\" Jones"]
        let string = "{{dropLast (replace (uppercase data.name) \"MIKE\" \"JAMES\") 6}}"
        throwsErrorWhenUnableToInterpolate(string, data: data, expectedError: .argumentCount(4))
    }

    func test_evaluatingExpressions_removeSurroundingQuotationMarksInDataSource_throwsError() throws {
        let data = ["name": "\"Mike\""]
        let string = "{{dropLast (dropFirst data.name 1) 1}} {{dropFirst (dropLast data.name 1) 1}}"
        throwsErrorWhenUnableToInterpolate(string, data: data, expectedError: .argumentCount(3))
    }


    // MARK: - TestHelpers

    private func makeSUT(
        _ initialString: String,
        data: Any? = nil,
        properties: UserInfo = .init(),
        dateFormatter: DateFormatter = localizedDateFormatter,
        customizableNumberFormatter: CustomizableNumberFormatter = canadianNumberFormatter
    ) throws -> String {
        try ExpressionEvaluator(
            data: data,
            properties: properties,
            dateFormatter: dateFormatter,
            customizableNumberFormatter: customizableNumberFormatter
        ).evaluate(string: initialString)
    }

    private func constructUserInfo(with parameters: [String: Any]) throws -> UserInfo {
        var userInfo = UserInfo()
        for entry in parameters {
            switch entry.value {
            case let json as JSON:
                userInfo[entry.key] = json
            case let string as String:
                userInfo[entry.key] = .string(string)
            case let int as Int:
                userInfo[entry.key] = .double(Double(int))
            case let double as Double:
                userInfo[entry.key] = .double(double)
            case let bool as Bool:
                userInfo[entry.key] = .bool(bool)
            default:
                throw Invalid(parameter: entry.value)
            }
        }
        return userInfo
    }

    private func constructComponentProperties(with parameters: [String: Any]) throws -> UserInfo {
        try constructUserInfo(with: parameters)
    }

    private struct Invalid: Error {
        let parameter: Any?
    }

    private func unexpectedValueError() -> StringExpressionError {
        StringExpressionError.unexpectedValue
    }

    private func throwsErrorWhenUnableToInterpolate(
        _ string: String,
        data: Any? = nil,
        properties: UserInfo = .init(),
        expectedError: StringExpressionError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try makeSUT(
                string,
                data: data,
                properties: properties
            ),
            "Expected error but interpolated \(string) without throwing",
            file: file,
            line: line
        ) { error in
            if let unwrappedError = error as? StringExpressionError {
                XCTAssertEqual(unwrappedError, expectedError)
            } else  {
                XCTFail("Expected \(expectedError) but got \(error.localizedDescription)")
            }
        }
    }

    private func throwsErrorWithIncorrectNumberOfArguments(
        _ helper: String,
        expectedArguments: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for count in 0...expectedArguments {
            if count == expectedArguments - 1 { // subtract 1 because the helper is the first argument
                continue
            }
            let extraArguments = Array(repeating: "extra", count: count).joined(separator: " ")
            let string = "{{\(helper) \(extraArguments)}}"
            throwsErrorWhenUnableToInterpolate(
                string,
                expectedError: .argumentCount(expectedArguments),
                file: file,
                line: line
            )
        }
    }

    private func throwsErrorWhenAnIntegerArgumentIsMissing(
        _ string: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let data = ["name": "Mr. Smith"]
        throwsErrorWhenUnableToInterpolate("{{\(string) data.name four}}", data: data, expectedError: .expectedInteger, file: file, line: line)
    }

    private func nonInterpolatedString() -> String {
        "NON_INTERPOLATED_STRING"
    }

    /// A DateFormatter that has its locale and timeZone set so that tests involving dates can pass
    private static let localizedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    private static let canadianNumberFormatter: CustomizableNumberFormatter = {
        let formatter = CustomizableNumberFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        return formatter
    }()
}


