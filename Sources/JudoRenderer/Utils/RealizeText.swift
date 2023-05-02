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

struct RealizeText<Content>: SwiftUI.View where Content: SwiftUI.View {
    @EnvironmentObject private var localizations: DocumentLocalizations
    @Environment(\.properties) private var properties
    @Environment(\.data) private var data

    private var text: TextValue
    private var content: (String) -> Content

    init(_ text: TextValue, @ViewBuilder content: @escaping (String) -> Content) {
        self.text = text
        self.content = content
    }

    var body: some View {
        content(
            text.resolve(
                data: data,
                properties: properties,
                locale: Locale.preferredLocale,
                localizations: localizations
            )
        )
    }

}
