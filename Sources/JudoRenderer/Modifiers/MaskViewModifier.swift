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

struct MaskViewModifier: SwiftUI.ViewModifier {
    var modifier: JudoDocument.MaskModifier

    func body(content: Content) -> some SwiftUI.View {
        if #available(macOS 12.0, iOS 15.0, *) {
            content
                .mask(alignment: alignment) {
                    self.content
                }
        } else {
            content
                .mask(self.content) // TODO: fake it
        }
    }
    
    @ViewBuilder private var content: some SwiftUI.View {
        SwiftUI.ZStack {
            ForEach(orderedNodes, id: \.id) {
                NodeView(node: $0)
            }
        }
    }

    private var orderedNodes: [Node] {
        modifier.children.reversed()
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
