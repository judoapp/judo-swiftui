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

struct ShadowViewModifier: SwiftUI.ViewModifier {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    var modifier: JudoDocument.ShadowModifier

    func body(content: Content) -> some SwiftUI.View {
        RealizeColor(modifier.color) { realizedColor in
            content
                .shadow(
                    color: realizedColor,
                    radius: radius,
                    x: offset.width,
                    y: offset.height
                )
        }
    }

    private var offset: CGSize {
        CGSize(
            width: modifier.offsetWidth.forceResolve(
                properties: componentState.properties,
                data: data
            ),
            height: modifier.offsetHeight.forceResolve(
                properties: componentState.properties,
                data: data
            )
        )
    }

    private var radius: CGFloat {
        modifier.radius.forceResolve(
            properties: componentState.properties,
            data: data
        )
    }
}
