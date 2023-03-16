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

struct ImageView: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties
    @EnvironmentObject private var assets: Assets

    @ObservedObject private var image: JudoModel.Image

    init(image: JudoModel.Image) {
        self.image = image
    }

    var body: some SwiftUI.View {
        switch image.kind {
        case .system(let systemName, let renderingMode):
            SwiftUI.Image(systemName: systemName)
                .modifier(SymbolRenderingModeViewModifier(renderingMode: renderingMode))
        case .content(let name, let resizing, let renderingMode):
            image(name: name, label: Text(image.label.description))
                .resizable(resizing)
                .renderingMode(renderingMode.swiftUIValue)
        case .decorative(let name, let resizing, let renderingMode):
            SwiftUI.Image(decorative: name)
                .resizable(resizing)
                .renderingMode(renderingMode.swiftUIValue)
        }
    }

    private func image(name: String, label: SwiftUI.Text) -> SwiftUI.Image {
        if let imageMeta = assets.image(
            named: name,
            appearance: colorScheme == .dark ? .dark : nil,
            scale: assetPreferredScale,
            strictAppearanceMatch: false,
            searchOtherScale: true
        ), let uiImage = UIImage(data: imageMeta.data, scale: imageMeta.scale) {
            return SwiftUI.Image(uiImage: uiImage)
        } else {
            return SwiftUI.Image(name, label: label)
        }
    }

    private var assetPreferredScale: Assets.Scale {
        switch displayScale {
        case 1:
            return .one
        case 2:
            return .two
        case 3:
            return .three
        default:
            return .three
        }
    }

}

private extension SwiftUI.Image {
    func resizable(_ resizing: JudoModel.ResizingMode) -> SwiftUI.Image {
        switch resizing {
        case .none:
            return self
        case .tile:
            return resizable(resizingMode: .tile)
        case .stretch:
            return resizable(resizingMode: .stretch)
        }
    }
}

private struct SymbolRenderingModeViewModifier: SwiftUI.ViewModifier {
    let renderingMode: JudoModel.SymbolRenderingMode
    func body(content: Content) -> some SwiftUI.View {
        if #available(iOS 15.0, *) {
            content
                .symbolRenderingMode(renderingMode.swiftUIValue)
        } else {
            content
        }
    }
}

