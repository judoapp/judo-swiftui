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

/// Realize a GradientReference into a SwiftUI view that renders the the gradient, accounting for the DocumentGradients getting updated.
struct RealizeGradient<Content>: SwiftUI.View where Content: SwiftUI.View {
    @Environment(\.document) private var document
    
    var gradientReference: GradientReference?
    var content: (GradientValue) -> Content
    
    init(_ gradientReference: GradientReference? = nil, @ViewBuilder content: @escaping (GradientValue) -> Content) {
        self.gradientReference = gradientReference
        self.content = content
    }
    
    @ViewBuilder
    var body: some SwiftUI.View {
        switch gradientReference?.referenceType {
        case .custom:
            if let gradientValue = gradientReference?.customGradient {
                content(gradientValue)
            }
        case .document:
            if let documentGradientID = gradientReference?.documentGradientID,
                let documentGradient = document.gradients.first(where: { $0.id == documentGradientID }) {
                ObserveDocumentGradient(documentGradient: documentGradient, content: content)
            }
        case nil:
            content(GradientValue(from: .zero, to: CGPoint(x: 1, y: 1), stops: []))
        }
    }
}

private struct ObserveDocumentGradient<Content>: SwiftUI.View where Content: SwiftUI.View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var documentGradient: DocumentGradient
    
    var content: (GradientValue) -> Content
    
    var body: some SwiftUI.View {
        content(gradientValue)
    }
    
    private var gradientValue: GradientValue {
        let darkMode = colorScheme == .dark
        let highContrast = colorSchemeContrast == .increased
        
        // prefer tightest match of selectors.  Fault backwards through tightest matches of selectors until getting to the base gradient.
        let variant: GradientValue?
        if darkMode, highContrast {
            variant = documentGradient.variants[[.darkMode, .highContrast]]
                ?? documentGradient.variants[[.darkMode]]
                ?? documentGradient.variants[[.highContrast]]
        } else if darkMode {
            variant = documentGradient.variants[[.darkMode]]
        } else if highContrast {
            variant = documentGradient.variants[[.highContrast]]
        } else {
            variant = nil
        }
        
        return variant ?? documentGradient.gradient
    }
}

extension GradientValue {
    func swiftUIGradient(startPoint: SwiftUI.UnitPoint? = nil, endPoint: SwiftUI.UnitPoint? = nil) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(
                stops: stops
                    .sorted { $0.position < $1.position }
                    .map { Gradient.Stop(color: $0.color.swiftUIColor, location: CGFloat($0.position)) }
            ),
            startPoint: startPoint ?? .init(x: from.x, y: from.y),
            endPoint: endPoint ?? .init(x: to.x, y: to.y)
        )
    }
}

private extension ColorValue {
    var swiftUIColor: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
}
