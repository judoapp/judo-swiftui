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

public enum AssetSource<Value: AssetValue>: Codable, Hashable {
    /// A short media item stored in-band within the Judo file.
    case fromFile(value: Value)
    
    /// A streamable media source available through the network.
    case fromURL(url: String)
    
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case assetName
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        let caseName = try container.decode(String.self, forKey: .caseName)
        switch caseName {
        case "fromFile":
            let assetName = try container.decode(String.self, forKey: .assetName)
            guard let assetValue: Value = coordinator.assetByFilename(assetName) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .assetName,
                    in: container,
                    debugDescription: "Missing asset file: \(assetName)"
                )
            }
            self = .fromFile(value: assetValue)
        case "fromURL":
            let url = try container.decode(String.self, forKey: .url)
            self = .fromURL(url: url)
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
        case .fromFile(let value):
            try container.encode("fromFile", forKey: .caseName)
            try container.encode(value.filename, forKey: .assetName)
        case .fromURL(let url):
            try container.encode("fromURL", forKey: .caseName)
            try container.encode(url, forKey: .url)
        }
    }
        
    public var url: String? {
        switch self {
        case .fromFile(_):
            return nil
        case .fromURL(let url):
            return url
        }
    }
    
    public var assetValue: Value? {
        switch self {
        case .fromFile(let value):
            return value
        case .fromURL(_):
            return nil
        }
    }
}


extension AssetSource {
    // Audio
    public static var audioPlaceholder: AssetSource<MediaValue> {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-audio", withExtension: "mp3")!
        let value = try! MediaValue(url: url)
        return .fromFile(value: value)
    }
    
    public static var audioURLPlaceholder: AssetSource<MediaValue> {
        let url = "https://content.judo.app/media/f95c944e8c411552e5554e1bb3b63b6615013425ae0749dd3c55d0c6fd615c1b.mp3"
        return .fromURL(url: url)
    }
    
    // Video
    public static var videoPlaceholder: AssetSource<MediaValue> {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-video", withExtension: "mp4")!
        let value = try! MediaValue(url: url)
        return .fromFile(value: value)
    }
    
    public static var videoURLPlaceholder: AssetSource<MediaValue> {
        let url = "https://content.judo.app/media/c3bb8dda92b46e4a9fa5389e0afc8d411e70d47996d5640c2c6096a0f99ccbb3.mp4"
        return .fromURL(url: url)
    }
    
    // Image
    public static var imagePlaceholder: AssetSource<ImageValue> {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-image", withExtension: "png")!
        let value = try! ImageValue(url: url)
        return .fromFile(value: value)
    }

    public static var imageCurrentPageIndicatorPlaceholder: AssetSource<ImageValue> {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-page-indicator-current", withExtension: "png")!
        let value = try! ImageValue(url: url)
        return .fromFile(value: value)
    }

    public static var imagePageIndicatorPlaceholder: AssetSource<ImageValue> {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-page-indicator", withExtension: "png")!
        let value = try! ImageValue(url: url)
        return .fromFile(value: value)
    }

    public static var imageURLPlaceholder: AssetSource<ImageValue> {
        let url = "https://content.judo.app/images/placeholder.png"
        return .fromURL(url: url)
    }
}
