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

struct PresentationBackgroundInteractionViewModifier: SwiftUI.ViewModifier {
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var modifier: PresentationBackgroundInteractionModifier

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationBackgroundInteraction(interaction)
            } else {
               content
            }
    }

    @available(iOS 16.4, *)
    private var interaction: SwiftUI.PresentationBackgroundInteraction {
        switch modifier.interaction {
        case .automatic:
            return .automatic
        case .enabled:
            return .enabled
        case .disabled:
            return .disabled
        case .upThrough:
            guard let detent = modifier.detent else { return .automatic }

            switch detent.standardDetent {
            case .medium:
                return .enabled(upThrough: .medium)
            case .large:
                return .enabled(upThrough: .large)
            case .none:
                break
            }

            if let fractionValue = detent.fractionValue {
                let resolvedValue = fractionValue.forceResolve(propertyValues: componentBindings.propertyValues, data: data)

                return .enabled(upThrough: .fraction(resolvedValue))
            }

            if let heightValue = detent.heightValue {
                let resolvedValue = heightValue.forceResolve(propertyValues: componentBindings.propertyValues, data: data)

                return .enabled(upThrough: .height(resolvedValue))
            }
            
            return .automatic
        }
    }
}
