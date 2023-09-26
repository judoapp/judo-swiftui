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

struct LineLimitViewModifier: SwiftUI.ViewModifier {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    @ObservedObject var modifier: LineLimitModifier
    
    func body(content: Content) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {
            if let range {
                content
                    .lineLimit(range)
            } else {
                content
            }
        } else if let upperBound = range?.upperBound {
            content
                .lineLimit(upperBound)
        } else {
            content
        }
    }

    private var range: ClosedRange<Int>? {
        modifier.effectiveRange(minValue: minValue, maxValue: maxValue)
    }

    private var minValue: Int? {
        let resolvedValue = modifier.min?.forceResolve(
            properties: componentState.properties,
            data: data
        )
        
        return resolvedValue.map { Int($0) }
    }

    private var maxValue: Int? {
        let resolvedValue = modifier.max?.forceResolve(
            properties: componentState.properties,
            data: data
        )
        
        return resolvedValue.map { Int($0) }
    }
}


