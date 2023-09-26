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

public final class Form: Layer, Modifiable {

    required public init() {
        super.init()
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let form = super.copy(with: zone) as! Form
        return form
    }

    // MARK: Hierarchy

    override public var isLeaf: Bool {
        false
    }

    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is Layer.Type, is JudoModifier.Type:
            return true
        default:
            return false
        }
    }

    // MARK: Codable

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
