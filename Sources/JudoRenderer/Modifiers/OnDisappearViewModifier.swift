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

struct OnDisappearViewModifier: SwiftUI.ViewModifier {
    var modifier: JudoDocument.OnDisappearModifier

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .modifier(OnDisappear_iOS15_Modifier(actions: modifier.onDisappearActions))
        } else {
            content
                .modifier(OnDisappear_Legacy_Modifier(actions: modifier.onDisappearActions))
        }
    }
}

@available(iOS 15.0, *)
private struct OnDisappear_iOS15_Modifier: SwiftUI.ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]

    func body(content: Content) -> some View {
        content
            .onDisappear {
                Actions.perform(
                    actions: actions,
                    componentState: componentState,
                    data: data,
                    actionHandlers: actionHandlers
                ) {
                   dismiss()
                } openURL: { url in
                    openURL(url)
                } refresh: {
                    Task {
                        await refresh?()
                    }
                }
        }
    }
}

private struct OnDisappear_Legacy_Modifier: SwiftUI.ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]

    func body(content: Content) -> some View {
        content
            .onDisappear {
                Actions.perform(
                    actions: actions,
                    componentState: componentState,
                    data: data,
                    actionHandlers: actionHandlers
                ) {
                    presentationMode.wrappedValue.dismiss()
                } openURL: { url in
                    openURL(url)
                }
            }
    }
}
