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

struct TextFieldView: SwiftUI.View {
    @Environment(\.componentBindings) private var componentBindings
    @Environment(\.data) private var data

    var textField: JudoDocument.TextFieldLayer

    var body: some SwiftUI.View {
        // Get the realizedText for the Label
        RealizeText(textField.title, localized: true) { title in

            // Get the realizedText for the text/value binding
            RealizeText(textField.text, localized: false) { text in

                if case .property(let name) = textField.text.binding {
                    switch componentBindings[name]?.wrappedValue {
                    case is Double:
                        SwiftUI.TextField(title, value: numberValueBinding(text), formatter: NumberFormatter.allowsFloatsNumberFormatter)
                    default:
                        textField(title: title, text: text)
                    }
                } else {
                    textField(title: title, text: text)
                }
            }
        }
    }

    private func textField(title: String, text: String) -> some View {
        if #available(iOS 16.0, *) {
            return SwiftUI.TextField(title, text: textValueBinding(text), axis: axis)
        } else {
            return SwiftUI.TextField(title, text: textValueBinding(text))
        }
    }

    private func textValueBinding(_ value: String) -> Binding<String> {
        Binding {
            value
        } set: { newValue in
            if case .property(let name) = textField.text.binding {
                switch componentBindings[name]?.wrappedValue {
                case is String:
                    componentBindings[name]?.wrappedValue = newValue
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
                switch componentBindings[name]?.wrappedValue {
                case is Double:
                    if let newValue {
                        componentBindings[name]?.wrappedValue = newValue
                    }
                default:
                    break
                }
            }
        }
    }

    private var axis: SwiftUI.Axis {
        switch textField.axis {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}

private extension NumberFormatter {
    static let allowsFloatsNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal // This allows the TextField to accept numbers with decimal points
        formatter.usesGroupingSeparator = false // We need to set this to false so that we do not end up displaying numbers as 1,000.23 instead of 1000.23
        formatter.maximumFractionDigits = 10 // We need to allow a maximum number of decimal places otherwise it will only allow 3.
        return formatter
    }()
}
