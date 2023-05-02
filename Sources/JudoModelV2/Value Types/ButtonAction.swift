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

import SwiftUI
import OrderedCollections

public enum ButtonAction: Codable, Hashable {

    public typealias Parameters = OrderedDictionary<String, ParameterValue>

    public enum ParameterValue: Codable, Hashable, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral {
        case text(String)
        case number(Double)
        case boolean(Bool)

        public init(stringLiteral value: StringLiteralType) {
            self = .text(value)
        }

        public init(floatLiteral value: FloatLiteralType) {
            self = .number(value)
        }

        public init(integerLiteral value: IntegerLiteralType) {
            self = .number(Double(value))
        }

        public init(booleanLiteral value: BooleanLiteralType) {
            self = .boolean(value)
        }
    }

    case `none`
    case dismiss
    case openURL(TextValue)
    case refresh
    case custom(CustomActionIdentifier, Parameters)
}

extension ButtonAction.Parameters {
    public mutating func addItem() {
        let index = (1...).first { index in
            self["key\(index)"] == nil
        } ?? 1

        // Start all initial values as strings
        self["key\(index)"] = .text("value")
    }
}
