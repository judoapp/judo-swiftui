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

struct MinimumScaleFactorViewModifier: SwiftUI.ViewModifier {
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var modifier: MinimumScaleFactorModifier

    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(scaleFactor)
    }

    private var scaleFactor: Double {
        let scaleFactor = modifier.scaleFactor.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )

        // The scale factor should be between 0 and 1
        if scaleFactor < 0 { return 0 }
        if scaleFactor > 1 { return 1 }

        return scaleFactor
    }
}
