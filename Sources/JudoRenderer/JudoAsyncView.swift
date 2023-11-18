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

import Combine
import JudoDocument
import SwiftUI

public struct JudoAsyncView<Content>: View where Content: View {
    @State private var phase: JudoAsyncViewPhase = .empty
    
    private var url: URL?
    private var content: (JudoAsyncViewPhase) -> Content
    
    public init(url: URL?) where Content == _ConditionalContent<JudoView, Color> {
        self.init(
            url: url,
            content: { judoView in
                judoView
            }, placeholder: {
                Color(UIColor.secondarySystemBackground)
            }
        )
    }
    
    public init<C, P>(
        url: URL?,
        @ViewBuilder content: @escaping (JudoView) -> C,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<C, P>, C : View, P : View {
        self.url = url
        
        @ViewBuilder func conditionalContent(
            phase: JudoAsyncViewPhase,
            @ViewBuilder content: @escaping (JudoView) -> C,
            @ViewBuilder placeholder: @escaping () -> P
        ) -> _ConditionalContent<C, P> {
            if let judoView = phase.judoView {
                content(judoView)
            } else {
                placeholder()
            }
        }
        
        self.content = { phase in
            conditionalContent(
                phase: phase,
                content: content,
                placeholder: placeholder
            )
        }
    }
    
    public init(
        url: URL?,
        @ViewBuilder content: @escaping (JudoAsyncViewPhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    public var body: some View {
        if case .empty = phase, let url {
            content(phase).onAppear {
                download(url: url)
            }
        } else {
            content(phase)
        }
    }
    
    private func download(url: URL) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                let response = response as! HTTPURLResponse
                let judoError = JudoError.downloadFailed(statusCode: response.statusCode, underlyingError: error)
                self.phase = .failure(judoError)
            } else if let data {
                guard let document = try? DocumentNode.read(from: data) else {
                    self.phase = .failure(JudoError.dataCorrupted)
                    return
                }
                
                guard !document.components.isEmpty else {
                    self.phase = .failure(.emptyFile)
                    return
                }
                
                self.phase = .success(JudoView(document: document))
            }
        }
        
        task.resume()
    }
}
