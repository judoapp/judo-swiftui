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

struct BlendModeViewModifier: SwiftUI.ViewModifier {
    var modifier: BlendModeModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .blendMode(blendMode)
    }
    
    private var blendMode: SwiftUI.BlendMode {
        switch modifier.blendMode {
        case .color:
            return .color
        case .colorBurn:
            return .colorBurn
        case .colorDodge:
            return .colorDodge
        case .darken:
            return .darken
        case .destinationOut:
            return .destinationOut
        case .destinationOver:
            return .destinationOver
        case .difference:
            return .difference
        case .exclusion:
            return .exclusion
        case .hardLight:
            return .hardLight
        case .hue:
            return .hue
        case .lighten:
            return .lighten
        case .luminosity:
            return .luminosity
        case .multiply:
            return .multiply
        case .normal:
            return .normal
        case .overlay:
            return .overlay
        case .plusDarker:
            return .plusDarker
        case .plusLighter:
            return .plusLighter
        case .saturation:
            return .saturation
        case .screen:
            return .screen
        case .softLight:
            return .softLight
        case .sourceAtop:
            return .sourceAtop
        }
    }
}
