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

struct ButtonView: SwiftUI.View {
    @ObservedObject var button: JudoModel.Button

    var body: some SwiftUI.View {
        if #available(iOS 15.0, *) {
            ButtonWithRole(
                action: button.buttonAction,
                role: button.role.swiftUIValue,
                content: content
            )
        } else {
            ButtonWithoutRole(
                action: button.buttonAction,
                content: content
            )
        }
    }

    private var content: some SwiftUI.View {
        ForEach(button.children.allOf(type: Layer.self)) {
            LayerView(layer: $0)
        }
    }
}

private struct ButtonWithoutRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.presentationMode) private var presentationMode

    let action: ButtonAction
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button {
            switch action {
            case .`none`:
                break

            case .dismiss:
                presentationMode.wrappedValue.dismiss()

            case .openURL(let url):
                if let url = URL(string: url.description) {
                    openURL(url)
                }

            case .refresh:
                logger.info("Refresh is unavailable on iOS 14")
                assertionFailure("Refresh is unavailable on iOS 14")
                break

            case .custom(let name, let userInfo):
                customActions[name]?(userInfo)
            }
        } label: {
            content
        }
    }
}

@available(iOS 15.0, *)
private struct ButtonWithRole<Content: SwiftUI.View>: SwiftUI.View {
    @Environment(\.openURL) private var openURL
    @Environment(\.customActions) private var customActions
    @Environment(\.dismiss) private var dismiss // Only available in iOS 15+
    @Environment(\.refresh) private var refresh // Only available in iOS 15+

    let action: ButtonAction
    let role: SwiftUI.ButtonRole?
    let content: Content

    var body: some SwiftUI.View {
        SwiftUI.Button(role: role) {
            switch action {
            case .`none`:
                break

            case .dismiss:
                dismiss()

            case .openURL(let url):
                if let url = URL(string: url.description) {
                    openURL(url)
                }

            case .refresh:
                Task {
                    await refresh?()
                }

            case .custom(let name, let userInfo):
                customActions[name]?(userInfo)
            }
        } label: {
            content
        }
    }
}
