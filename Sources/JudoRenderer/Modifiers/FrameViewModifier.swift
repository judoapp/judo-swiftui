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

struct FrameViewModifier: SwiftUI.ViewModifier {
    @Environment(\.data) private var data
    @Environment(\.componentBindings) private var componentBindings
    
    var modifier: JudoDocument.FrameModifier

    func body(content: Content) -> some SwiftUI.View {
        switch modifier.frameType {
        case .fixed:
            content
                .frame(width: width, height: height, alignment: alignment)
        case .flexible:
            content
                .frame(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    alignment: alignment
                )
        }
    }
    
    private var width: CGFloat? {
        let resolvedValue = modifier.width?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var maxWidth: CGFloat? {
        let resolvedValue = modifier.maxWidth?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var minWidth: CGFloat? {
        let resolvedValue = modifier.minWidth?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var height: CGFloat? {
        let resolvedValue = modifier.height?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var maxHeight: CGFloat? {
        let resolvedValue = modifier.maxHeight?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var minHeight: CGFloat? {
        let resolvedValue = modifier.minHeight?.forceResolve(
            propertyValues: componentBindings.propertyValues,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
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
