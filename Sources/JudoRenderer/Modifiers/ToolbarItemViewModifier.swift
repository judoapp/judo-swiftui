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

struct ToolbarItemViewModifier: SwiftUI.ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject var modifier: ToolbarItemModifier

    func body(content: Content) -> some SwiftUI.View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    let item = modifier.toolbarItem
                    switch item.action {
                    case .none:
                        LabelView(item: item)

                    case .dismiss:

                        if #available(iOS 15.0, *) {
                            DismissToolbarItemButtonView(item: item)
                        } else {
                            ToolbarItemButtonView(item: item) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }

                    case .refresh:
                        if #available(iOS 15.0, *) {
                            RefreshableButtonView(item: item)
                        } else {
                            ToolbarItemButtonView(item: item) {
                                logger.info("Refresh is unavailable on iOS 14")
                                assertionFailure("Refresh is unavailable on iOS 14")
                            }
                        }

                    case .openURL(let url):
                        ToolbarItemButtonView(item: item) {
                            if let url = URL(string: url.description) {
                                openURL(url)
                            }
                        }

                    case .custom:
                        ToolbarItemButtonView(item: item) {
                            // TODO: Handle custom actions with Name and UserInfo
                        }
                    }
                }
            }
    }

    var placement: SwiftUI.ToolbarItemPlacement {
        switch modifier.toolbarItem.placement {
            // Leading Items
        case .leading:
            return .navigationBarLeading
        case .cancellation:
            return .cancellationAction
        case .navigation:
            return .navigation

            // Center Items
        case .principal:
            return .principal

            // Trailing Items
        case .automatic:
            return .automatic
        case .trailing:
            return .navigationBarTrailing
        case .primary:
            return .primaryAction
        case .confirmation:
            return .confirmationAction
        case .destruction:
            return .destructiveAction
        case .secondary:
            if #available(iOS 16.0, *) {
                return .secondaryAction
            } else {
                return .primaryAction
            }
        }
    }
}

@available(iOS 15.0, *)
private struct DismissToolbarItemButtonView: SwiftUI.View {
    @Environment(\.dismiss) private var dismiss
    let item: ToolbarItemModifier.ToolbarItem

    var body: some SwiftUI.View {
        ToolbarItemButtonView(item: item) {
                dismiss()
        }
    }
}

@available(iOS 15.0, *)
private struct RefreshableButtonView: SwiftUI.View {
    @Environment(\.refresh) private var refresh
    let item: ToolbarItemModifier.ToolbarItem

    var body: some SwiftUI.View {
        ToolbarItemButtonView(item: item, action: {
            Task {
                await refresh?()
            }
        })
    }
}

private struct ToolbarItemButtonView: SwiftUI.View {
    let item: ToolbarItemModifier.ToolbarItem
    let action: () -> Void

    var body: some SwiftUI.View {
        Button {
            action()
        } label: {
            LabelView(item: item)
        }
    }
}

private struct LabelView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties

    let item: ToolbarItemModifier.ToolbarItem

    var body: some SwiftUI.View {
        if let icon = item.icon, let title = title {
            SwiftUI.Label(title, systemImage: icon.symbolName)
        } else if let icon = item.icon {
            SwiftUI.Image(systemName: icon.symbolName)
        } else if let title = title {
            SwiftUI.Text(title)
        }
    }

    private var title: String? {
        try? item.title?.description.evaluatingExpressions(
            data: data,
            properties: properties
        )
    }
}
