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
        if modifier.isFlexible {
            content
                .frame(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    alignment: alignment
                )
        } else {
            content
                .frame(width: width, height: height, alignment: alignment)
        }
    }
    
    private var width: CGFloat? {
        modifier.width?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var maxWidth: CGFloat? {
        modifier.maxWidth?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var minWidth: CGFloat? {
        modifier.minWidth?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var height: CGFloat? {
        modifier.height?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var maxHeight: CGFloat? {
        modifier.maxHeight?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var minHeight: CGFloat? {
        modifier.minHeight?
            .resolve(data: data, componentState: componentState)
            .map { CGFloat($0) }
    }
    
    private var alignment: SwiftUI.Alignment {
        modifier.alignment.swiftUIValue
    }
}
