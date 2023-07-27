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

struct ShadowViewModifier: SwiftUI.ViewModifier {
    @ObservedObject var modifier: JudoModel.ShadowModifier

    @ComponentValue private var offsetWidth: NumberValue
    @ComponentValue private var offsetHeight: NumberValue
    @ComponentValue private var radius: NumberValue

    init(modifier: JudoModel.ShadowModifier) {
        self.modifier = modifier
        self.offsetWidth = modifier.offsetWidth
        self.offsetHeight = modifier.offsetHeight
        self.radius = modifier.radius
    }

    func body(content: Content) -> some SwiftUI.View {
        RealizeColor(modifier.color) { realizedColor in
            content
                .shadow(
                    color: realizedColor,
                    radius: $radius ?? 0,
                    x: $offsetWidth ?? 0,
                    y: $offsetHeight ?? 0
                )
        }
    }
}
