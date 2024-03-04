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

struct CombinedTextView: SwiftUI.View {
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.sizeCategory) private var sizeCategory

    @Environment(\.document) private var document
    var combinedText: CombinedTextLayer

    var body: some SwiftUI.View {
        if combinedLayers.count == 0 {
            EmptyView()
        } else {
            combinedLayers.reduce(Text("")) { result, value in
                let textLayer = value.0
                let string = value.1
                return result + Text(string).modifiers(for: textLayer, documentNode: document, sizeCategory: sizeCategory, colorScheme: colorScheme, colorSchemeContrast: colorSchemeContrast, propertyValues: componentState.propertyValues, data: data)
            }
        }
    }

    private var textLayers: [TextLayer] {
        combinedText.children.compactMap {
            $0 as? TextLayer
        }
    }

    private var combinedLayers: [(TextLayer, String)] {
        textLayers.map { textLayer in
            (
                textLayer,
                realizeText(textLayer.value, localized: true, strings: document.strings, propertyValues: componentState.propertyValues, data: data)
            )
        }
    }
}


private extension Text {

    func modifiers(for textLayer: TextLayer, documentNode: DocumentNode, sizeCategory: SwiftUI.ContentSizeCategory, colorScheme: SwiftUI.ColorScheme, colorSchemeContrast: SwiftUI.ColorSchemeContrast, propertyValues: [String : PropertyValue], data: Any?) -> Text {
        let modifiers = textLayer.children.compactMap { node in
            node as? Modifier
        }

        return modifiers.reduce(self) {
            text,
            modifier in
            switch modifier {
            case let modifier as FontModifier:
                return text.font(
                    realizeFont(
                        modifier.font,
                        documentNode: documentNode,
                        sizeCategory: sizeCategory,
                        propertyValues: propertyValues,
                        data: data
                    )
                )
            case is BoldModifier:
                return text.bold()
            case is ItalicModifier:
                return text.italic()
            case let modifier as UnderlineModifier:
                let isActive = modifier.isActive.forceResolve(propertyValues: propertyValues, data: data)
                let underlineColor = realizeColor(modifier.color, documentNode: documentNode, colorScheme: colorScheme, colorSchemeContrast: colorSchemeContrast)
                if #available(iOS 16.0, *) {
                    return text.underline(isActive, pattern: modifier.pattern.swiftUIValue, color: underlineColor)
                } else {
                    return text.underline(isActive, color: underlineColor)
                }
            case let modifier as KerningModifier:
                let kerning = modifier.kerning.forceResolve(propertyValues: propertyValues, data: data)
                return text.kerning(kerning)
            case let modifier as TrackingModifier:
                let tracking = modifier.tracking.forceResolve(propertyValues: propertyValues, data: data)
                return text.kerning(tracking)
            case let modifier as ForegroundColorModifier:
                return text.foregroundColor(
                    realizeColor(modifier.color, documentNode: documentNode, colorScheme: colorScheme, colorSchemeContrast: colorSchemeContrast)
                )
            case let modifier as FontWeightModifier:
                return text.fontWeight(modifier.weight.swiftUIValue)
            case let modifier as AccessibilityLabelModifier:
                if #available(iOS 15.0, *) {
                    let label = modifier.label.forceResolve(propertyValues: propertyValues, data: data)
                    return text.accessibilityLabel(label)
                } else {
                    return text
                }
            default:
                return text
            }
        }
    }
}
