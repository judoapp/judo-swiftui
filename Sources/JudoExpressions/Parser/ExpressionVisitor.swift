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

package protocol ExpressionVisitor {
    func visitCallExpr(_ expr: Call) throws -> Any?
    func visitMethodExpr(_ expr: CallMethod) throws -> Any?
    func visitIdentifierExpr(_ expr: Identifier) throws -> Any?
    func visitLiteralStringExpr(_ expr: LiteralString) throws -> Any?
    func visitLiteralStringInterpolationExpr(_ expr: LiteralStringInterpolation) throws -> Any?
    func visitLiteralNumberExpr(_ expr: LiteralNumber) throws -> Any?
    func visitLiteralBoolExpr(_ expr: LiteralBool) throws -> Any?
    func visitLiteralNilExpr(_ expr: LiteralNil) throws -> Any?
    func visitGroupingExpr(_ expr: Grouping) throws -> Any?
    func visitUnaryExpr(_ expr: Unary) throws -> Any?
    func visitBinaryExpr(_ expr: Binary) throws -> Any?
}
