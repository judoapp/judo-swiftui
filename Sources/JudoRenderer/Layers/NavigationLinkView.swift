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

struct NavigationLinkView: SwiftUI.View {
    @Environment(\.assetManager) private var assetManager
    @Environment(\.customActions) private var customActions
    @Environment(\.data) private var data
    @Environment(\.document) private var document
    @Environment(\.fetchedImage) private var fetchedImage
    
    @EnvironmentObject private var componentState: ComponentState

    var navigationLink: JudoDocument.NavigationLinkNode
    var body: some SwiftUI.View {
        NavigationLink {
            ForEach(navigationLink.children[1].children, id: \.id) {
                NodeView(node: $0)
            }
            .environment(\.assetManager, assetManager)
            .environment(\.customActions, customActions)
            .environment(\.data, data)
            .environment(\.document, document)
            .environment(\.fetchedImage, fetchedImage)
            .environmentObject(componentState)
        } label: {
            ForEach(navigationLink.children[0].children, id: \.id) {
                NodeView(node: $0)
            }
        }
    }
}
