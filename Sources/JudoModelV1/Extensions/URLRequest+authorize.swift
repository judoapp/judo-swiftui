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

extension URLRequest {
    mutating func authorize(with authorizers: [Authorizer]) {
        guard let url = url,
              let host = url.host else {
            return
        }
                
        for authorizer in authorizers {
            let wildcardAndRoot = authorizer.pattern.components(separatedBy: "*.")
            guard let root = wildcardAndRoot.last, wildcardAndRoot.count <= 2 else {
                break
            }
            
            let hasWildcard = wildcardAndRoot.count > 1
            
            if (!hasWildcard && host == authorizer.pattern) || (hasWildcard && (host == root || host.hasSuffix(".\(root)"))) {
                switch authorizer.method {
                case .header:
                    setValue(authorizer.value, forHTTPHeaderField: authorizer.key)
                case .queryString:
                    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                        continue
                    }
                    
                    var queryItems = components.queryItems ?? []
                    
                    let queryItem = URLQueryItem(name: authorizer.key, value: authorizer.value)
                    queryItems.append(queryItem)
                    components.queryItems = queryItems
                    self.url = components.url
                }
            }
        }
    }
}
