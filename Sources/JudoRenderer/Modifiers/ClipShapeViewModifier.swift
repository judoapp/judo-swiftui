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

struct ClipShapeViewModifier: SwiftUI.ViewModifier {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    var modifier: ClipShapeModifier

    func body(content: Content) -> some SwiftUI.View {
        switch modifier.shape {
        case let capsule as JudoDocument.CapsuleNode:
            content
                .clipShape(
                    SwiftUI.Capsule(style: capsule.cornerStyle.swiftUIValue),
                    style: fillStyle
                )

        case is JudoDocument.CircleNode:
            content
                .clipShape(
                    SwiftUI.Circle(),
                    style: fillStyle
                )

        case is JudoDocument.EllipseNode:
            content
                .clipShape(
                    SwiftUI.Ellipse(),
                    style: fillStyle
                )

        case is JudoDocument.RectangleNode:
            content
                .clipShape(
                    SwiftUI.Rectangle(),
                    style: fillStyle
                )

        case let roundedRectangle as JudoDocument.RoundedRectangleNode:
            content
                .clipShape(
                    SwiftUI.RoundedRectangle(
                        cornerRadius: cornerRadius(roundedRectangle.cornerRadius),
                        style: roundedRectangle.cornerStyle.swiftUIValue
                    ),
                    style: fillStyle
                )
        default:
            content
        }
    }

    private var fillStyle: SwiftUI.FillStyle {
        let eoFill = modifier.isEvenOddRule.forceResolve(properties: componentState.properties, data: data)
        let antialiased = modifier.isAntialiased.forceResolve(properties: componentState.properties, data: data)
        return FillStyle(eoFill: eoFill, antialiased: antialiased)
    }

    private func cornerRadius(_ cornerRadius: Variable<Double>) -> Double {
        cornerRadius.forceResolve(properties: componentState.properties, data: data)
    }
}

private extension JudoDocument.RoundedCornerStyle {
    var swiftUIValue: SwiftUI.RoundedCornerStyle {
          switch self {
          case .circular:
              return .circular
          case .continuous:
              return .continuous
          }
    }
}
