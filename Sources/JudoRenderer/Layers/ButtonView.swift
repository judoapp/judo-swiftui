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

struct ButtonView: SwiftUI.View {
    var button: JudoDocument.ButtonNode

    var body: some SwiftUI.View {
        if #available(iOS 15.0, *) {
            ButtonWithRole(
                actions: button.actions,
                role: role,
                content: content
            )
        } else {
            ButtonWithoutRole(
                actions: button.actions,
                content: content
            )
        }
    }

    private var content: some SwiftUI.View {
        ForEach(button.children, id: \.id) {
            NodeView(node: $0)
        }
    }

    @available(iOS 15.0, *)
    var role: SwiftUI.ButtonRole? {
        switch button.role {
        case .none:
            return .none
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

private struct ButtonWithoutRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button {
            Actions.perform(actions: actions, componentState: componentState, data: data, actionHandlers: actionHandlers) {
                presentationMode.wrappedValue.dismiss()
            } openURL: { url in
                openURL(url)
            }
        } label: {
            content
        }
    }
}

@available(iOS 15.0, *)
private struct ButtonWithRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    let actions: [Action]
    let role: SwiftUI.ButtonRole?
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button(role: role) {
            Actions.perform(actions: actions, componentState: componentState, data: data, actionHandlers: actionHandlers) {
                dismiss()
            } openURL: { url in
                openURL(url)
            } refresh: {
                Task {
                    await refresh?()
                }
            }
        } label: {
            content
        }
    }
}
