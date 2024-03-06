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

/// replace with specialised Literals
package struct LiteralNil: Expression {

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralNilExpr(self)
    }
}

package struct LiteralBool: Expression {
    package let literal: Bool

    init(_ literal: Bool) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralBoolExpr(self)
    }
}

package struct LiteralNumber: Expression {
    package let literal: Double

    init(_ literal: Double) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralNumberExpr(self)
    }
}

package struct LiteralString: Expression {
    package let literal: String

    init(_ literal: String) {
        self.literal = literal
    }

    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralStringExpr(self)
    }
}

package struct LiteralStringInterpolation: Expression {
    package let expression: any Expression

    init(expression: any Expression) {
        self.expression = expression
    }
    
    package func accept(_ visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteralStringInterpolationExpr(self)
    }
}
