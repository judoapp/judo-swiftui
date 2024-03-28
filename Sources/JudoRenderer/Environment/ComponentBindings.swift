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

import JudoDocument
import SwiftUI

typealias ComponentBindings = [String: Binding<Any>]

extension ComponentBindings {
    var propertyValues: [String: PropertyValue] {
        reduce(into: [:]) { partialResult, element in
            switch element.value.wrappedValue {
            case let value as String:
                partialResult[element.key] = .text(value)
            case let value as Double:
                partialResult[element.key] = .number(value)
            case let value as Bool:
                partialResult[element.key] = .boolean(value)
            case let value as ImageReference:
                partialResult[element.key] = .image(value)
            case let value as UUID:
                partialResult[element.key] = .component(value)
            case let value as Video:
                partialResult[element.key] = .video(value)
            case let value as Expression<String>:
                partialResult[element.key] = .computed(.text(value))
            case let value as Expression<Double>:
                partialResult[element.key] = .computed(.number(value))
            case let value as Expression<Bool>:
                partialResult[element.key] = .computed(.boolean(value))
            default:
                break
            }
        }
    }
}
