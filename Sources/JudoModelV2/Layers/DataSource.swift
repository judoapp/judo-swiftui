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

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif
import Combine

public final class DataSource: Layer {
    override public class var humanName: String {
        "Data Source"
    }
    
    /// A publisher that publishes requests for the data source to be refreshed.
    public let refresh = PassthroughSubject<Void, Never>()
    
    public static let defaultSource = "https://reqres.in/api/users"
    
    public enum HTTPMethod: String, Codable, CaseIterable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }

    public struct Header: Codable, Hashable {
        public var key: String
        public var value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    public var url = DataSource.defaultSource { willSet { objectWillChange.send() } }
    public var httpMethod: HTTPMethod = .get { willSet { objectWillChange.send() } }
    public var httpBody: String? { willSet { objectWillChange.send() } }
    public var headers = [Header]() { willSet { objectWillChange.send() } }
    public var pollInterval: Int? { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    public init(name: String, url: String = DataSource.defaultSource, httpMethod: HTTPMethod = .get, httpBody: String? = nil, headers: [Header] = [], pollInterval: Int? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.headers = headers
        self.pollInterval = pollInterval
        super.init()
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is Layer.Type:
            return true
        default:
            return false
        }
    }

    override public var traits: Traits {
        .lockable
    }
        
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let dataSource = super.copy(with: zone) as! DataSource
        dataSource.url = url
        dataSource.httpMethod = httpMethod
        dataSource.httpBody = httpBody
        dataSource.headers = headers
        dataSource.pollInterval = pollInterval
        return dataSource
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case url
        case httpMethod
        case httpBody
        case headers
        case pollInterval
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pollInterval = try container.decodeIfPresent(Int.self, forKey: .pollInterval)
        url = try container.decode(String.self, forKey: .url)
        httpMethod = try container.decode(HTTPMethod.self, forKey: .httpMethod)
        httpBody = try container.decodeIfPresent(String.self, forKey: .httpBody)
        headers = try container.decode([Header].self, forKey: .headers)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(httpMethod, forKey: .httpMethod)
        try container.encodeIfPresent(httpBody, forKey: .httpBody)
        try container.encode(headers, forKey: .headers)
        try container.encodeIfPresent(pollInterval, forKey: .pollInterval)
        try super.encode(to: encoder)
    }
}

// MARK: URL Request

extension DataSource {
    public func urlRequest(data: Any?, properties: MainComponent.Properties) throws -> URLRequest {
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
