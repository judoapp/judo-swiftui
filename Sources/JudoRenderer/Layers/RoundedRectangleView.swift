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

struct RoundedRectangleView: SwiftUI.View {
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var roundedRectangle: JudoDocument.RoundedRectangleLayer

    var body: some SwiftUI.View {
        SwiftUI.RoundedRectangle(cornerRadius: cornerRadius, style: style)
            .apply(model: roundedRectangle)
    }

    private var cornerRadius: Double {
        roundedRectangle.cornerRadius.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
    }
    
    private var style: SwiftUI.RoundedCornerStyle {
          switch roundedRectangle.cornerStyle {
          case .circular:
              return .circular
          case .continuous:
              return .continuous
          }
    }
}
