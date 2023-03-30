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

@available(iOS, deprecated: 15.0)
@available(macOS, deprecated: 12.0)
public extension Backport where Wrapped == Any {

    enum AsyncImagePhase {
        /// No image is loaded.
        case empty
        /// An image succesfully loaded.
        case success(SwiftUI.Image)
        /// An image failed to load with an error.
        case failure(Error)

        /// The loaded image, if any.
        public var image: SwiftUI.Image? {
            guard case let .success(image) = self else { return nil }
            return image
        }

        /// The error that occurred when attempting to load an image, if any.
        public var error: Error? {
            guard case let .failure(error) = self else { return nil }
            return error
        }
    }

    struct AsyncImage<Content: SwiftUI.View>: SwiftUI.View {
        @State private var phase: AsyncImagePhase = .empty

        var url: URL?
        var scale: CGFloat
        var transaction: Transaction
        var content: (AsyncImagePhase) -> Content

        public init(url: URL?, scale: CGFloat = 1) where Content == SwiftUI.AnyView {
            self.url = url
            self.scale = scale
            self.transaction = Transaction()
            self.content = { AnyView($0.image) }
        }

        public init<I, P>(url: URL?, scale: CGFloat = 1, @ViewBuilder content: @escaping (SwiftUI.Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P> {
            self.url = url
            self.scale = scale
            self.transaction = Transaction()
            self.content = { phase -> _ConditionalContent<I, P> in
                if let image = phase.image {
                    return SwiftUI.ViewBuilder.buildEither(first: content(image))
                } else {
                    return SwiftUI.ViewBuilder.buildEither(second: placeholder())
                }
            }
        }

        public init(url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
            self.url = url
            self.scale = scale
            self.transaction = transaction
            self.content = content
        }

        public var body: some SwiftUI.View {
            ZStack {
                content(phase)
            }
            .modifier(
                LoaderViewModifier(
                    url: url,
                    scale: scale,
                    transaction: transaction,
                    phase: $phase
                )
            )
        }
    }

    private struct LoaderViewModifier: SwiftUI.ViewModifier {
        let url: URL?
        let scale: CGFloat
        let transaction: Transaction

        @Binding var phase: AsyncImagePhase
        @State private var task: Task<Void, Never>?

        func body(content: Self.Content) -> some SwiftUI.View {
            content
                .onChange(of: url) { url in
                    task?.cancel()
                    task = Task {
                        await load(url: url, scale: scale)
                    }
                }
                .onAppear {
                    task?.cancel()
                    task = Task {
                        await load(url: url, scale: scale)
                    }
                }
                .onDisappear {
                    task?.cancel()
                    task = nil
                }
        }

        func load(url: URL?, scale: CGFloat) async {
            do {
                guard !Task.isCancelled else { return }
                guard let url = url else {
                    throw NSError(domain: "judo.app", code: 0)
                }
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }

#if os(macOS)
                if let image = NSImage(data: data, scale: scale) {
                    withTransaction(transaction) {
                        phase = .success(Image(nsImage: image))
                    }
                }
#else
                if let image = UIImage(data: data, scale: scale) {
                    withTransaction(transaction) {
                        phase = .success(Image(uiImage: image))
                    }
                }
#endif
            } catch {
                phase = .failure(error)
            }
        }
    }

}

#if os(macOS)
private extension NSImage {

    /// Initializes and returns the image object with the specified data and scale factor.
    /// - Parameters:
    ///   - data: The data object containing the image data.
    ///   - scale: The scale factor to assume when interpreting the image data. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the size property.
    convenience init?(data: Data, scale: CGFloat) {

        self.init(data: data)

        if !scale.isZero {
            self.size = NSSize(width: size.width / scale, height: size.height / scale)
        }
    }
}
#endif
