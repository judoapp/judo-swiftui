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

struct SecureFieldView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @EnvironmentObject private var localizations: DocumentLocalizations

    @ObservedObject var secureField: JudoModel.SecureField

    var body: some SwiftUI.View {
        RealizeText(secureField.title, localized: true) { title in
            RealizeText(secureField.text, localized: false) { text in
                SwiftUI.SecureField(title, text: textValueBinding(text))
            }
        }
    }

    private func textValueBinding(_ value: String) -> Binding<String> {
        Binding {
            value
        } set: { newValue in
            if case .property(let name) = secureField.text.binding {
                componentState.bindings[name]?.value = .text(newValue)
            }
        }
    }
}
