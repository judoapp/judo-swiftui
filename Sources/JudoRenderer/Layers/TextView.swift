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

import Foundation
import SwiftUI
import JudoDocument

struct TextView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.isBold) private var isBold
    @Environment(\.isItalic) private var isItalic
    @Environment(\.isUnderlined) private var isUnderlined

    private var text: JudoDocument.TextNode

    init(text: JudoDocument.TextNode) {
        self.text = text
    }

    var body: some SwiftUI.View {
        RealizeText(text.value) { text in
            textContent(text)
        }
    }
    
    @ViewBuilder
    private func textContent(_ string: String) -> some View {
        /// Apply the .bold() and .italic() modifiers if running less than iOS 16, as outlined in Backport+bold and Backport+italic.
        if #available(iOS 16, macOS 13, *) {
            SwiftUI.Text(string)
        } else {

            switch (isBold, isItalic, isUnderlined.isActive) {
            case (true, true, true):
                SwiftUI.Text(string)
                    .bold()
                    .italic()
                    .underline(isUnderlined.isActive, color: isUnderlined.color)
            case (true, true, false):
                SwiftUI.Text(string)
                    .bold()
                    .italic()
            case (true, false, true):
                SwiftUI.Text(string)
                    .bold()
                    .underline(isUnderlined.isActive, color: isUnderlined.color)
            case (false, true, true):
                SwiftUI.Text(string)
                    .italic()
                    .underline(isUnderlined.isActive, color: isUnderlined.color)
            case (true, false, false):
                SwiftUI.Text(string)
                    .bold()
            case (false, true, false):
                SwiftUI.Text(string)
                    .italic()
            case (false, false, true):
                SwiftUI.Text(string)
                    .underline(isUnderlined.isActive, color: isUnderlined.color)
            case (false, false, false):
                SwiftUI.Text(string)
            }
        }
    }
}
