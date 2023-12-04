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

struct FullScreenCoverViewModifier: SwiftUI.ViewModifier {

    var modifier: FullScreenCoverModifier

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .modifier(FullScreenCover_iOS15_Modifier(modifier: modifier))
        } else {
            content
                .modifier(FullScreenCover_Legacy_Modifier(modifier: modifier))
        }
    }
}

@available(iOS 15.0, *)
private struct FullScreenCover_iOS15_Modifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState

    var modifier: FullScreenCoverModifier

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: isPresented, onDismiss: {
                Actions.perform(actions: modifier.onDismissActions, componentState: componentState, data: data, actionHandlers: actionHandlers) {
                    dismiss()
                } openURL: { url in
                    openURL(url)
                } refresh: {
                    Task {
                        await refresh?()
                    }
                }
            }) {
                self.content
            }
    }

    @ViewBuilder
    private var content: some SwiftUI.View {
        SwiftUI.ZStack {
            ForEach(orderedNodes, id: \.id) {
                NodeView(node: $0)
            }
        }
    }

    private var orderedNodes: [Node] {
        modifier.children.reversed()
    }

    private var isPresented: Binding<Bool> {
        Binding {
            if let name = modifier.isPresentedPropertyName,
                let value = componentState.bindings[name]?.value,
                case let .boolean(booleanValue) = value {
                return booleanValue
            } else {
                return false
            }

        } set: { newValue in
            guard let name = modifier.isPresentedPropertyName else { return }
            componentState.bindings[name]?.value = .boolean(newValue)
        }
    }
}

private struct FullScreenCover_Legacy_Modifier: SwiftUI.ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    var modifier: FullScreenCoverModifier

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: isPresented, onDismiss: {
                Actions.perform(actions: modifier.onDismissActions, componentState: componentState, data: data, actionHandlers: actionHandlers) {
                    presentationMode.wrappedValue.dismiss()
                } openURL: { url in
                    openURL(url)
                }
            }) {
                self.content
            }
    }

    @ViewBuilder
    private var content: some SwiftUI.View {
        SwiftUI.ZStack {
            ForEach(orderedNodes, id: \.id) {
                NodeView(node: $0)
            }
        }
    }

    private var orderedNodes: [Node] {
        modifier.children.reversed()
    }

    private var isPresented: Binding<Bool> {
        Binding {
            if let name = modifier.isPresentedPropertyName,
                let value = componentState.bindings[name]?.value,
                case let .boolean(booleanValue) = value {
                return booleanValue
            } else {
                return false
            }

        } set: { newValue in
            guard let name = modifier.isPresentedPropertyName else { return }
            componentState.bindings[name]?.value = .boolean(newValue)
        }
    }
}
