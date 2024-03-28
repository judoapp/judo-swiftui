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
import JudoDocument

struct ImageView: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.data) private var data
    @Environment(\.fetchedImage) private var fetchedImage
    @Environment(\.componentBindings) private var componentBindings
    
    private var image: JudoDocument.ImageLayer

    init(image: JudoDocument.ImageLayer) {
        self.image = image
    }
    
    var body: some SwiftUI.View {
        ImageReferenceView(
            imageReference: image.value.forceResolve(
                propertyValues: componentBindings.propertyValues,
                data: data,
                fetchedImage: fetchedImage
            ),
            resizing: image.resizing,
            renderingMode: image.renderingMode,
            symbolRenderingMode: image.symbolRenderingMode
        )
    }
}

struct ImageReferenceView: View {
    var imageReference: ImageReference
    var resizing: ResizingMode
    var renderingMode: TemplateRenderingMode
    var symbolRenderingMode: JudoDocument.SymbolRenderingMode
    
    var body: some View {
        switch imageReference {
        case .document(let imageName):
            DocumentImageView(
                name: imageName,
                resizing: resizing,
                renderingMode: renderingMode
            )
        case .system(let imageName):
            SystemImageView(
                systemName: imageName,
                renderingMode: symbolRenderingMode
            )
        case .inline(let image):
            InlineImageView(
                image: image,
                resizing: resizing,
                renderingMode: renderingMode
            )
        }
    }
}

private struct DocumentImageView: View {
    @Environment(\.assetManager) private var assetManager
    @Environment(\.colorScheme) private var colorScheme

    let name: String
    let resizing: JudoDocument.ResizingMode
    let renderingMode: JudoDocument.TemplateRenderingMode

    var body: some View {
        if let image {
            InlineImageView(
                image: image,
                resizing: resizing,
                renderingMode: renderingMode
            )
        } else {
            MissingImageView()
        }
    }

    private var image: SwiftUI.Image? {
        guard let uiImage else {
            return nil
        }
        
        return SwiftUI.Image(uiImage: uiImage)
    }
    
    private var uiImage: UIImage? {
        guard let imageMeta else {
            return nil
        }
        
        return UIImage(data: imageMeta.data, scale: imageMeta.scale)
    }
    
    private var imageMeta: (data: Data, scale: CGFloat)? {
        if colorScheme == .light {
            return assetManager.image(named: name, appearance: nil, scale: .two, strictAppearanceMatch: true, searchOtherScale: true)
        } else {
            return assetManager.image(named: name, appearance: .dark, scale: .two, strictAppearanceMatch: false, searchOtherScale: true)
        }
    }
}

private struct InlineImageView: View {
    let image: SwiftUI.Image
    let resizing: JudoDocument.ResizingMode
    let renderingMode: JudoDocument.TemplateRenderingMode

    var body: some View {
        switch renderingMode {
        case .original:
            image
                .resizable(resizing)
        case .template:
            image
                .resizable(resizing)
                .renderingMode(.template)
        }
    }
}

private extension SwiftUI.Image {
    func resizable(_ resizing: JudoDocument.ResizingMode) -> SwiftUI.Image {
        switch resizing {
        case .none:
            return self
        case .tile:
            return self.resizable(resizingMode: .tile)
        case .stretch:
            return self.resizable(resizingMode: .stretch)
        }
    }
}

private struct SystemImageView: View {
    let systemName: String
    let renderingMode: JudoDocument.SymbolRenderingMode

    var body: some View {
        SwiftUI.Image(systemName: systemName)
            .modifier(SymbolRenderingModeViewModifier(renderingMode: renderingMode))
    }
}

private struct SymbolRenderingModeViewModifier: ViewModifier {
    let renderingMode: JudoDocument.SymbolRenderingMode
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .symbolRenderingMode(swiftUIValue)
        } else {
            content
        }
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    private var swiftUIValue: SwiftUI.SymbolRenderingMode {
        switch renderingMode {
        case .hierarchical:
            return .hierarchical
        case .monochrome:
            return .monochrome
        case .multicolor:
            return .multicolor
        }
    }
}

private struct MissingImageView: View {
    var body: some View {
        SwiftUI.Image(systemName: "exclamationmark.triangle")
            .foregroundColor(Color(.systemYellow))
    }
}
