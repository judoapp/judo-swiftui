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

extension DataSourceNode {
    public func urlRequest(data: Any?, properties: Properties) throws -> URLRequest {
        let urlString = try url.evaluatingExpressions(
            data: data,
            properties: properties
        )
        
        guard
            let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedURLString)
        else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.httpBody = try? httpBody?
            .evaluatingExpressions(
                data: data,
                properties: properties
            )
            .data(using: .utf8)
        
        request.allHTTPHeaderFields = headers.reduce(nil) { result, header in
            let maybeValue = try? header.value.evaluatingExpressions(
                data: data,
                properties: properties
            )
            
            guard let value = maybeValue else {
                return result
            }
                
            var nextResult = result ?? [:]
            nextResult[header.key] = value
            return nextResult
        }

        return request
    }
}
