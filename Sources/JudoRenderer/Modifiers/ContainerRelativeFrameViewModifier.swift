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

struct ContainerRelativeFrameViewModifier: SwiftUI.ViewModifier {
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var modifier: ContainerRelativeFrameModifier

    func body(content: Content) -> some View {
            if #available(iOS 17.0, *) {
                content
                    .containerRelativeFrame(
                        axes,
                        count: count,
                        span: span,
                        spacing: spacing,
                        alignment: alignment
                    )

            } else {
               content
            }
    }

    private var axes: SwiftUI.Axis.Set {
        switch modifier.axes {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        default:
            return [.vertical, .horizontal]
        }
    }

    private var count: Int {
        Int(modifier.count.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        ))
    }

    private var span: Int {
        Int(modifier.span.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        ))
    }

    private var spacing: Double {
        modifier.spacing.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
    }

    private var alignment: SwiftUI.Alignment {
        switch modifier.alignment {
        case .topLeading:
            return .topLeading
        case .top:
            return .top
        case .topTrailing:
            return .topTrailing
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .bottomLeading:
            return .bottomLeading
        case .bottom:
            return .bottom
        case .bottomTrailing:
            return .bottomTrailing
        case .firstTextBaselineLeading:
            return .leadingFirstTextBaseline
        case .firstTextBaseline:
            return .centerFirstTextBaseline
        case .firstTextBaselineTrailing:
            return .trailingFirstTextBaseline
        }
    }
}
