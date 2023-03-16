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

import JudoModel
import SwiftUI

struct CollectionView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties
    @EnvironmentObject private var documentState: DocumentData
    @ObservedObject var collection: CollectionLayer

    var body: some SwiftUI.View {
        if let items = items {
            ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                ForEach(layers) { layer in
                    LayerView(layer: layer)
                        .environment(\.data, item)
                }
                .contentShape(SwiftUI.Rectangle())
            }
        }
    }

    private var layers: [Layer] {
        collection.children.allOf(type: Layer.self)
    }

    private var items: [Any]? {
        collection.items(
            data: data,
            properties: properties
        )
    }
}

private extension CollectionLayer {
    func items(data: Any?, properties: MainComponent.Properties) -> [Any] {
        guard var result = JSONSerialization.value(forKeyPath: keyPath, data: data, properties: properties) as? [Any] else {
            return []
        }

        filters.forEach { condition in
            result = result.filter { data in
                condition.isSatisfied(
                    data: data,
                    properties: properties
                )
            }
        }

        if !sortDescriptors.isEmpty {
            result.sort { a, b in
                for descriptor in self.sortDescriptors {
                    let a = JSONSerialization.value(
                        forKeyPath: descriptor.keyPath,
                        data: a,
                        properties: properties
                    )

                    let b = JSONSerialization.value(
                        forKeyPath: descriptor.keyPath,
                        data: b,
                        properties: properties
                    )

                    switch (a, b) {
                    case (let a as String, let b as String) where a != b:
                        return descriptor.ascending ? a < b : a > b
                    case (let a as Double, let b as Double) where a != b:
                        return descriptor.ascending ? a < b : a > b
                    case (let a as Bool, let b as Bool) where a != b:
                        return descriptor.ascending ? a == false : a == true
                    case (let a as Date, let b as Date) where a != b:
                        return descriptor.ascending ? a < b : a > b
                    default:
                        break
                    }
                }

                return false
            }
        }

        if let limit = limit {
            let startAt = max(limit.startAt - 1, 0)
            let lowerBound = min(startAt, result.indices.upperBound)
            let limitedRange = result.indices.clamped(to: lowerBound..<result.endIndex)
            result = Array(result[limitedRange])
        }

        result = Array(result.prefix(limit?.show ?? 100))
        return result
    }
}

