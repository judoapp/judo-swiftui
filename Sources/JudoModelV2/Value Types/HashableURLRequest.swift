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

/// A hashable `URLRequest` that includes the `httpBody` and the `allHTTPHeaderFields`
///
/// `URLRequest` uses `NSURLRequest`'s `hash(into:)` method to hash the request.
///
/// - [URLRequest.swift#L236](https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/FoundationNetworking/URLRequest.swift#L236)
/// - [NSURLRequest.swift#L270](https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/FoundationNetworking/NSURLRequest.swift#L270)
///
/// When using `URLRequest` as a `Key` in a dictionary we can get collisions if the `httpBody` and/or the `allHTTPHeaderFields` are different
/// but the underlying `URLRequest` is the same. Wrapping the `URLRequest` inside a `HashableURLRequest` allows them to be included and stops the
/// collisions.
public struct HashableURLRequest: Hashable {
    public let urlRequest: URLRequest
    public let httpBody: Data?
    public let allHTTPHeaderFields: [String: String]?

    public init(_ urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        httpBody = urlRequest.httpBody
        allHTTPHeaderFields = urlRequest.allHTTPHeaderFields
    }
}
