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

extension SwiftUI.InsettableShape {
    @ViewBuilder
    func apply(model: JudoModel.Shape) -> some SwiftUI.View {
        switch model.rasterizationStyle {
        case .fill:
            applyFill(model: model)
        case .stroke:
            applyStroke(model: model)
        case .strokeBorder:
            applyStrokeBorder(model: model)
        }
    }
    
    @ViewBuilder
    private func applyFill(model: JudoModel.Shape) -> some SwiftUI.View {
        switch model.shapeStyle {
        case .flat(let colorRef):
            RealizeColor(
                colorRef
            ) { color in
                fill(color)
            }
        case .gradient(let gradientRef):
            RealizeGradient(gradientRef) { gradient in
                fill(gradient.swiftUIGradient())
            }
        }
    }
    
    @ViewBuilder
    private func applyStroke(model: JudoModel.Shape) -> some SwiftUI.View {
        switch model.shapeStyle {
        case .flat(let colorRef):
            RealizeColor(
                colorRef
            ) { color in
                stroke(
                    color,
                    lineWidth: model.lineWidth
                )
            }
        case .gradient(let gradientRef):
            RealizeGradient(gradientRef) { gradient in
                stroke(
                    gradient.swiftUIGradient(),
                    lineWidth: model.lineWidth
                )
            }
        }
    }
    
    @ViewBuilder
    private func applyStrokeBorder(model: JudoModel.Shape) -> some SwiftUI.View {
        switch model.shapeStyle {
        case .flat(let colorRef):
            RealizeColor(
                colorRef
            ) { color in
                
                strokeBorder(
                    color,
                    lineWidth: model.lineWidth
                )
            }
        case .gradient(let gradientRef):
            RealizeGradient(gradientRef) { gradient in
                strokeBorder(
                    gradient.swiftUIGradient(),
                    lineWidth: model.lineWidth
                )
            }
        }
    }
}
