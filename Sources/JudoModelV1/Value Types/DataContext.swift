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
import Foundation

public struct DataContext: Hashable {
    private struct Request: Hashable {
        var url: String
        var httpMethod: DataSource.HTTPMethod
        var httpBody: String?
        var headers: [DataSource.Header]
        var dataKeyPaths: [String]
    }
    
    private var requests = [Request]()
    
    public init() {
        
    }
    
    public mutating func add(dataSource: DataSource, collections: [CollectionNode]) {
        let request = DataContext.Request(
            url: dataSource.url,
            httpMethod: dataSource.httpMethod,
            httpBody: dataSource.httpBody,
            headers: dataSource.headers,
            dataKeyPaths: collections.map(\.keyPath)
        )
        
        requests.insert(request, at: 0)
    }
    
    public func adding(dataSource: DataSource, collections: [CollectionNode]) -> DataContext {
        var dataContext = self
        dataContext.add(dataSource: dataSource, collections: collections)
        return dataContext
    }
    
    public func publisher(urlParameters: UserInfo, userInfo: UserInfo, authorizers: [Authorizer], simulateSlowNetwork: Bool = false) -> AnyPublisher<Result<Any?, Error>, Never> {
        // Use subscript to return a subsequence so we can call popFirst
        var queue = requests[...]
        
        guard let firstRequest = queue.popFirst() else {
            return Just(.success(nil)).eraseToAnyPublisher()
        }
        
        func publisher(for request: Request, data: Any?) -> AnyPublisher<Result<Any?, Error>, Never> {
            guard let urlString = try? request.url.evaluatingExpressions(data: data, urlParameters: urlParameters, userInfo: userInfo),
                  let url = URL(string: urlString) else {
                return Just(.success(nil)).eraseToAnyPublisher()
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.httpMethod.rawValue
            
            urlRequest.httpBody = try? request.httpBody?
                .evaluatingExpressions(data: data, urlParameters: urlParameters, userInfo: userInfo)
                .data(using: .utf8)
            
            urlRequest.allHTTPHeaderFields = request.headers.reduce(nil) { result, header in
                guard let value = try? header.value.evaluatingExpressions(data: data, urlParameters: urlParameters, userInfo: userInfo) else {
                    return result
                }
                    
                var nextResult = result ?? [:]
                nextResult[header.key] = value
                return nextResult
            }
            
            urlRequest.authorize(with: authorizers)
            
            return URLSession.shared.dataPublisher(
                for: urlRequest,
                simulateSlowNetwork: simulateSlowNetwork
            )
            .flatMap { result -> AnyPublisher<Result<Any?, Error>, Never> in
                switch result {
                case .success(let data):
                    let nextData = request.dataKeyPaths.reduce(data) { result, keyPath in
                        var result = JSONSerialization.value(
                            forKeyPath: keyPath,
                            data: result,
                            urlParameters: urlParameters,
                            userInfo: userInfo
                        )

                        // If root element is an array, use first element of the array.
                        if let array = result as? [Any] {
                            result = array.first
                        }
                        
                        return result
                    }
                    
                    if let nextRequest = queue.popFirst() {
                        return publisher(for: nextRequest, data: nextData)
                    } else {
                        return Just(.success(nextData)).eraseToAnyPublisher()
                    }
                case .failure:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        }
        
        return publisher(for: firstRequest, data: nil)
    }

    public static func dataContext(for node: Node) -> DataContext {
        var result = DataContext()
        var collectionPath = [CollectionNode]()

        func context(for node: Node) -> DataContext {
            switch node {
            case let dataSource as DataSource:
                result.add(dataSource: dataSource, collections: collectionPath)
                collectionPath = []
            case let collection as CollectionNode:
                collectionPath.insert(collection, at: 0)
            default:
                break
            }

            switch node {
            case let screen as Screen:
                if let segue = screen.inboundSegues.first {
                    return context(for: segue.source)
                } else {
                    return result
                }
            default:
                if let parent = node.parent {
                    return context(for: parent)
                } else {
                    return result
                }
            }
        }

        return context(for: node)
    }
}

extension Node {

    /// Note: The property getter trigger requests for all its parents.
    ///       Don't use this property in a context of Canvas View.
    public var dataContext: DataContext {
        guard let parent = self.parent else {
            return DataContext()
        }
        
        return DataContext.dataContext(for: parent)
    }
}

