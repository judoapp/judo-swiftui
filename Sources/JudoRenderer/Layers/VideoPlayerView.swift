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

import AVKit
import JudoDocument
import SwiftUI

struct VideoPlayerView: SwiftUI.View {
    var videoPlayer: JudoDocument.VideoPlayerNode
    @State private var player: AVPlayer = AVPlayer()

    var body: some View {
        RealizeText(Variable("", binding: .property(name: videoPlayer.propertyName))) { urlString in
            if let url = URL(string: urlString) {
                VideoPlayer(videoPlayer: videoPlayer, url: url)
            } else {
                AVKit.VideoPlayer(player: nil)
            }
        }
    }
}

private struct VideoPlayer: SwiftUI.View {
    var videoPlayer: JudoDocument.VideoPlayerNode
    @State private var player: AVPlayer

    init(videoPlayer: JudoDocument.VideoPlayerNode, url: URL) {
        self._player = State(initialValue: AVPlayer(url: url))
        self.videoPlayer = videoPlayer
    }

    var body: some View {
        AVKit.VideoPlayer(player: player) {
            ForEach(overlay, id: \.id) {
                NodeView(node: $0)
            }
        }
    }

    private var overlay: [Node] {
        videoPlayer.children[0].children
    }
}
