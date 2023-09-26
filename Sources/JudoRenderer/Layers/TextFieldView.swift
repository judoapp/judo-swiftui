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

struct TextFieldView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data
    @EnvironmentObject private var localizations: DocumentLocalizations

    @ObservedObject var textField: JudoModel.TextField

    var body: some SwiftUI.View {
        // Get the realizedText for the Label
        RealizeText(textField.title, localized: true) { title in

            // Get the realizedText for the text/value binding
            RealizeText(textField.text, localized: false) { text in

                if case .property(let name) = textField.text.binding {
                    switch componentState.bindings[name]?.value {
                    case .number:
                        SwiftUI.TextField(title, value: numberValueBinding(text), formatter: NumberFormatter.allowsFloatsNumberFormatter)
                    default:
                        SwiftUI.TextField(title, text: textValueBinding(text))
                    }
                } else {
                    SwiftUI.TextField(title, text: textValueBinding(text))
                }

            }
        }
    }

    private func textValueBinding(_ value: String) -> Binding<String> {
        Binding {
            value
        } set: { newValue in
            if case .property(let name) = textField.text.binding {
                switch componentState.bindings[name]?.value {
                case .text:
                    componentState.bindings[name]?.value = .text(newValue)
                default:
                    break
                }
            }
        }
    }

    private func numberValueBinding(_ value: String) -> Binding<Double?> {
        Binding {
            Double(value)
        } set: { newValue in
            if case .property(let name) = textField.text.binding {
                switch componentState.bindings[name]?.value {
                case .number:
                    if let newValue {
                        componentState.bindings[name]?.value = .number(newValue)
                    }
                default:
                    break
                }
            }
        }
    }
}

