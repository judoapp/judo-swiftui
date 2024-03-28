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

struct SheetViewModifier: SwiftUI.ViewModifier {

    var modifier: SheetModifier

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .modifier(Sheet_iOS15_Modifier(modifier: modifier))
        } else {
            content
                .modifier(Sheet_Legacy_Modifier(modifier: modifier))
        }
    }
}

@available(iOS 15.0, *)
private struct Sheet_iOS15_Modifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+
    @Environment(\.data) private var data
    @Environment(\.componentBindings) private var componentBindings

    var modifier: SheetModifier

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresented, onDismiss: {
                Actions.perform(actions: modifier.onDismissActions, componentBindings: componentBindings, data: data, actionHandlers: actionHandlers) {
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
            modifier.isPresented.forceResolve(
                propertyValues: componentBindings.propertyValues,
                data: data
            )
        } set: { newValue in
            if case .property(let name) = modifier.isPresented.binding {
                componentBindings[name]?.wrappedValue = newValue
            }
        }
    }
}

private struct Sheet_Legacy_Modifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.actionHandlers) private var actionHandlers
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var modifier: SheetModifier

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresented, onDismiss: {
                Actions.perform(
                    actions: modifier.onDismissActions, componentBindings: componentBindings, data: data, actionHandlers: actionHandlers) {
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
            modifier.isPresented.forceResolve(
                propertyValues: componentBindings.propertyValues,
                data: data
            )
        } set: { newValue in
            if case .property(let name) = modifier.isPresented.binding {
                componentBindings[name]?.wrappedValue = newValue
            }
        }
    }
}
