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

struct AccessibilityAddTraitsViewModifier: SwiftUI.ViewModifier {
    @ObservedObject var modifier: AccessibilityAddTraitsModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .accessibilityAddTraits(swiftUITraits)
    }

    var swiftUITraits: SwiftUI.AccessibilityTraits {
        let traits = modifier.traits
        var swiftUITraits: SwiftUI.AccessibilityTraits = []

        if traits.contains(.isButton) {
            _ = swiftUITraits.update(with: .isButton)
        }
        if traits.contains(.isHeader) {
            _ = swiftUITraits.insert(.isHeader)
        }

        if traits.contains(.isLink) {
            _ = swiftUITraits.insert(.isLink)
        }

        if traits.contains(.isModal) {
            _ = swiftUITraits.insert(.isModal)
        }

        if traits.contains(.isSummaryElement) {
            _ = swiftUITraits.insert(.isSummaryElement)
        }

        if traits.contains(.startsMediaSession) {
            _ = swiftUITraits.insert(.startsMediaSession)
        }

        return swiftUITraits
    }
}
