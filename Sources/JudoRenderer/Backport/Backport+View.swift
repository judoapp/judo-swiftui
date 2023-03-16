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

import SwiftUI
import Introspect

extension Backport where Content: SwiftUI.View {
    
    @ViewBuilder
    func bold(_ isActive: Bool = true) -> some SwiftUI.View {
        if #available(iOS 16, *) {
            content.bold(isActive)
        } else {
            content
                .environment(\.isBold, isActive)
        }
    }
    
    @ViewBuilder
    func italic(_ isActive: Bool = true) -> some SwiftUI.View {
        if #available(iOS 16, *) {
            content.italic(isActive)
        } else {
            content
                .environment(\.isItalic, isActive)
        }
    }
    
    @ViewBuilder
    func tint(_ tint: Color?) -> some SwiftUI.View {
        if #available(iOS 15, *) {
            content.tint(tint)
        } else {
            content.accentColor(tint)
        }
    }
    
    @ViewBuilder
    func badge(_ count: Int) -> some SwiftUI.View {
        if #available(iOS 15, *) {
            content.badge(count)
        } else {
            content
        }
    }
}
