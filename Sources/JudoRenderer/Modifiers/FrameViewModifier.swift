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

struct FrameViewModifier: SwiftUI.ViewModifier {
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState
    
    @ObservedObject var modifier: JudoModel.FrameModifier

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
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var maxWidth: CGFloat? {
        let resolvedValue = modifier.maxWidth?.forceResolve(
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var minWidth: CGFloat? {
        let resolvedValue = modifier.minWidth?.forceResolve(
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var height: CGFloat? {
        let resolvedValue = modifier.height?.forceResolve(
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var maxHeight: CGFloat? {
        let resolvedValue = modifier.maxHeight?.forceResolve(
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var minHeight: CGFloat? {
        let resolvedValue = modifier.minHeight?.forceResolve(
            properties: componentState.properties,
            data: data
        )
            
        return resolvedValue.map { CGFloat($0) }
    }
    
    private var alignment: SwiftUI.Alignment {
        modifier.alignment.swiftUIValue
    }
}
