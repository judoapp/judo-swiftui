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
import Combine
import JudoModel
import Backport

struct AsyncImageView: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    @ObservedObject private var image: JudoModel.AsyncImage

    init(image: JudoModel.AsyncImage) {
        self.image = image
    }

    var body: some SwiftUI.View {
        if #available(iOS 15, *) {
            SwiftUI.AsyncImage(url: URL(string: resolvedURL), scale: image.scale.scale) { phase in
                if let image = phase.image {
                    imageView
                        .environment(\.fetchedImage, image)
                } else if phase.error != nil {
                    placeholderView
                } else {
                    placeholderView
                }
            }
            .id("\(resolvedURL) \(image.scale)")
        } else {
            Backport.AsyncImage(url: URL(string: resolvedURL), scale: image.scale.scale) { phase in
                if let image = phase.image {
                    image
                } else if phase.error != nil {
                    placeholderView
                } else {
                    placeholderView
                }
            }
            .id("\(resolvedURL) \(image.scale)")
        }
    }

    @ViewBuilder
    private var imageView: some View {
        ForEach(image.content.children.allOf(type: Layer.self)) {
            LayerView(layer: $0)
        }
    }
    @ViewBuilder
    private var placeholderView: some View {
        ForEach(image.placeholder.children.allOf(type: Layer.self)) {
            LayerView(layer: $0)
        }
    }

    private var resolvedURL: String {
        image.url.forceResolve(
            properties: componentState.properties,
            data: data
        )
    }
}
