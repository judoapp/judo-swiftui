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

extension KeyedEncodingContainer {
    mutating func encodeActions(_ actions: [Action], forKey key: K) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        for action in actions {
            switch action {
            case let action as CustomAction:
                try container.encode(action)
            case let action as DecrementPropertyAction:
                try container.encode(action)
            case let action as DismissAction:
                try container.encode(action)
            case let action as IncrementPropertyAction:
                try container.encode(action)
            case let action as OpenURLAction:
                try container.encode(action)
            case let action as RefreshAction:
                try container.encode(action)
            case let action as SetPropertyAction:
                try container.encode(action)
            case let action as TogglePropertyAction:
                try container.encode(action)
            default:
                throw EncodingError.invalidValue(
                    action,
                    EncodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid value: \(action)"
                    )
                )
            }
        }
    }
}
