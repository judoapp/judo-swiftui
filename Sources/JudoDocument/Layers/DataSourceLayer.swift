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

public struct DataSourceLayer: Layer {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var frame: Frame
    public var isLocked: Bool
    public var url: String
    public var httpMethod: HTTPMethod
    public var httpBody: String?
    public var headers: [HTTPHeader]
    public var pollInterval: Int?
        
    public init(id: UUID, name: String?, children: [Node], position: CGPoint, frame: Frame, isLocked: Bool, url: String, httpMethod: HTTPMethod, httpBody: String?, headers: [HTTPHeader], pollInterval: Int?) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.frame = frame
        self.isLocked = isLocked
        self.url = url
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.headers = headers
        self.pollInterval = pollInterval
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case frame
        case isLocked
        case url
        case httpMethod
        case httpBody
        case headers
        case pollInterval
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)

        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<23:
            frame = Frame()
        default:
            frame = try container.decode(Frame.self, forKey: .frame)
        }

        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        pollInterval = try container.decodeIfPresent(Int.self, forKey: .pollInterval)
        url = try container.decode(String.self, forKey: .url)
        httpMethod = try container.decode(HTTPMethod.self, forKey: .httpMethod)
        httpBody = try container.decodeIfPresent(String.self, forKey: .httpBody)
        headers = try container.decode([HTTPHeader].self, forKey: .headers)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(frame, forKey: .frame)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(url, forKey: .url)
        try container.encode(httpMethod, forKey: .httpMethod)
        try container.encodeIfPresent(httpBody, forKey: .httpBody)
        try container.encode(headers, forKey: .headers)
        try container.encodeIfPresent(pollInterval, forKey: .pollInterval)
    }
}
