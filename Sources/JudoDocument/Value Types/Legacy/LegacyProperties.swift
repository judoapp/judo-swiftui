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
import OrderedCollections

typealias LegacyProperties = OrderedDictionary<String, LegacyProperty>

extension LegacyProperties {
    var properties: [Property] {
        self.map { element in
            switch element.value {
            case .text(let string):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .text(string)
                )
            case .number(let double):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .number(double)
                )
            case .boolean(let bool):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .boolean(bool)
                )
            case .image(let imageReference):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .image(imageReference)
                )
            case .component(let id):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .component(id)
                )
            case .video(let url):
                return Property(
                    id: UUID(),
                    name: element.key,
                    value: .video(Video(url: url))
                )
            }
        }
    }
}
