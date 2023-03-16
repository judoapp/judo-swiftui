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

/// Realize a ColorVariants into a UIColor or SwiftUI.Color.
struct RealizeColor<Content>: SwiftUI.View where Content: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var colorReference: ColorReference?
    private var swiftUIContent: ((Color) -> Content)? = nil
    private var cocoaContent: ((UIColor) -> Content)? = nil

    init(_ colorReference: ColorReference?, @ViewBuilder content: @escaping (Color) -> Content) {
        self.colorReference = colorReference
        self.swiftUIContent = content
    }

    init(_ colorReference: ColorReference?, @ViewBuilder cocoaContent: @escaping (UIColor) -> Content) {
        self.colorReference = colorReference
        self.cocoaContent = cocoaContent
    }

    var body: some SwiftUI.View {
        // this code is gross. Wasn't able to figure out an elegant solution given the constraints.
        guard let colorReference = colorReference else {
            if let swiftUIContent = swiftUIContent {
                return AnyView(swiftUIContent(.clear))
            }
            if let cocoaContent = cocoaContent {
                return AnyView(cocoaContent(.clear))
            }
            return AnyView(EmptyView())
        }

        if colorReference.referenceType == .system, let systemName = colorReference.systemColorName {
            if let swiftUIContent = swiftUIContent {
                return AnyView(swiftUIContent(Color.named(systemName)))
            }
            if let cocoaContent = cocoaContent {
                return AnyView(cocoaContent(UIColor.named(systemName)))
            }
        }

        if colorReference.referenceType == .document, let documentColor = colorReference.documentColor {
            if let swiftUIContent = swiftUIContent {
                return AnyView(ObserveDocumentColor(documentColor, content: swiftUIContent))
            }
            if let cocoaContent = cocoaContent {
                return AnyView(ObserveDocumentColor(documentColor, content: cocoaContent))
            }
        }

        if colorReference.referenceType == .custom, let customColor = colorReference.customColor {
            if let swiftUIContent = swiftUIContent {
                return AnyView(swiftUIContent(customColor.color))
            }
            if let cocoaContent = cocoaContent {
                return AnyView(cocoaContent(customColor.uiColor))
            }
        }

        if let swiftUIContent = swiftUIContent {
            return AnyView(swiftUIContent(.clear))
        }
        if let cocoaContent = cocoaContent {
            return AnyView(cocoaContent(.clear))
        }
        return AnyView(EmptyView())
    }
}

private struct ObserveDocumentColor<Content>: SwiftUI.View where Content: SwiftUI.View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    internal init(_ documentColor: DocumentColor, @ViewBuilder content: @escaping (Color) -> Content) {
        self.documentColor = documentColor
        self.swiftUIContent = content
    }

    internal init(_ documentColor: DocumentColor, @ViewBuilder content: @escaping (UIColor) -> Content) {
        self.documentColor = documentColor
        self.cocoaContent = content
    }

    var swiftUIContent: ((Color) -> Content)? = nil
    var cocoaContent: ((UIColor) -> Content)? = nil

    @ObservedObject var documentColor: DocumentColor

    var body: some SwiftUI.View {
        if let swiftUIContent = swiftUIContent {
            return AnyView(
                swiftUIContent(
                    documentColor.resolveColor(
                        darkMode: colorScheme == .dark,
                        highContrast: colorSchemeContrast == .increased
                    ).color
                )
            )
        }
        if let uiKitContent = cocoaContent {
            return AnyView(
                uiKitContent(
                    documentColor.resolveColor(
                        darkMode: colorScheme == .dark,
                        highContrast: colorSchemeContrast == .increased
                    ).uiColor
                )
            )
        }
        return AnyView(EmptyView())
    }
}

private extension ColorValue {
    var uiColor: UIColor {
        UIColor(displayP3Red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
