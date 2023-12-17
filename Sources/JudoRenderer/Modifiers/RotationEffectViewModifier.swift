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

struct RotationEffectViewModifier: SwiftUI.ViewModifier {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    var modifier: JudoDocument.RotationEffectModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .rotationEffect(angle, anchor: anchor)
    }

    private var angle: Angle {
        switch modifier.angleUnit {
        case .degrees:
            return Angle(degrees: angleValue)
        case .radians:
            return Angle(radians: angleValue)
        }
    }

    private var angleValue: Double {
        modifier.angleSize.forceResolve(propertyValues: componentState.propertyValues, data: data)
    }
    
    private var anchor: SwiftUI.UnitPoint {
        switch modifier.anchor {
        case .bottom:
            return .bottom
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        case .center:
            return .center
        case .leading:
            return .leading
        case .top:
            return .top
        case .topLeading:
            return .topLeading
        case .topTrailing:
            return .topTrailing
        case .trailing:
            return .trailing
        case .zero:
            return .zero
        }
    }
}
