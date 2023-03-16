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

public final class WebViewNode: Layer {
    override public class var humanName: String {
        "Web View"
    }
    
    public enum Source: Hashable {
        case url(String)
        case html(String)
    }
    
    public var source = Source.url("https://www.judo.app/") {
        willSet { objectWillChange.send() }
    }
    
    public var isScrollEnabled = false { willSet { objectWillChange.send() } }

    required public init() {
        super.init()
    }

    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .resizable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .layerable,
            .accessible,
            .metadatable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let webView = super.copy(with: zone) as! WebViewNode
        webView.source = source
        webView.isScrollEnabled = isScrollEnabled
        return webView
    }
    
    // MARK: Codable

    override public class var typeName: String {
        "WebView"
    }
    
    private enum CodingKeys: String, CodingKey {
        case source
        case isScrollEnabled
        case url // Legacy
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        if coordinator.documentVersion >= 9 {
            source = try container.decode(Source.self, forKey: .source)
        } else {
            let url = try container.decode(String.self, forKey: .url)
            source = .url(url)
        }
        
        isScrollEnabled = try container.decode(Bool.self, forKey: .isScrollEnabled)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(isScrollEnabled, forKey: .isScrollEnabled)
        try super.encode(to: encoder)
    }
}

extension WebViewNode.Source: Codable {
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseName = try container.decode(String.self, forKey: .caseName)
        let value = try container.decode(String.self, forKey: .value)
        switch caseName {
        case "url":
            self = .url(value)
        case "html":
            self = .html(value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .caseName,
                in: container,
                debugDescription: "Invalid value: \(caseName)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .url(let value):
            try container.encode("url", forKey: .caseName)
            try container.encode(value, forKey: .value)
        case .html(let value):
            try container.encode("html", forKey: .caseName)
            try container.encode(value, forKey: .value)
        }
    }
}
