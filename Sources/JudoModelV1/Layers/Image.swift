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

import SwiftUI
import os.log

public final class Image: Layer {
    public enum ResizingMode: String, Codable {
        case originalSize
        case scaleToFit
        case scaleToFill
        case tile
        case stretch
    }
    
    @objc public dynamic var originalFileName: String? { willSet { objectWillChange.send() } }
    public var source: AssetSource<ImageValue> { willSet { objectWillChange.send() } }
    public var darkModeSource: AssetSource<ImageValue>? { willSet { objectWillChange.send() } }
    public var resolution = CGFloat(1) { willSet { objectWillChange.send() } }
    public var resizingMode = ResizingMode.originalSize { willSet { objectWillChange.send() } }
    public var dimensions: CGSize? {
        source.assetValue?.image.size
    }

    public init(image: ImageValue) {
        source = .fromFile(value: image)
        super.init()
    }
    
    public init(url: String) {
        source = .fromURL(url: url)
        super.init()
    }
    
    required public init() {
        source = .imagePlaceholder
        resolution = 2
        super.init()
        originalFileName = "placeholder.png"
    }

    public convenience init?(fileURL url: URL) {
        guard let imageValue = try? ImageValue(url: url) else {
            return nil
        }
        
        self.init(image: imageValue)
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        return originalFileName ?? super.description
    }
    
    override public class var keyPathsAffectingDescription: Set<String> {
        ["originalFileName"]
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .layerable,
            .actionable,
            .accessible,
            .metadatable,
            .codePreview
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let image = super.copy(with: zone) as! Image
        image.originalFileName = originalFileName
        image.resolution = resolution
        image.resizingMode = resizingMode
        image.source = source
        image.darkModeSource = darkModeSource
        return image
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case originalFileName
        case source
        case darkModeSource
        case resolution
        case resizingMode
        case dimensions
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        if coordinator.documentVersion >= 10 {
            originalFileName = try container.decodeIfPresent(String.self, forKey: .originalFileName)
        }
        
        source = try container.decode(AssetSource.self, forKey: .source)
        darkModeSource = try container.decodeIfPresent(AssetSource.self, forKey: .darkModeSource)
        resolution = try container.decode(CGFloat.self, forKey: .resolution)
        resizingMode = try container.decode(ResizingMode.self, forKey: .resizingMode)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(originalFileName, forKey: .originalFileName)
        try container.encode(source, forKey: .source)
        try container.encodeIfPresent(darkModeSource, forKey: .darkModeSource)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(resizingMode, forKey: .resizingMode)
        try container.encodeIfPresent(dimensions, forKey: .dimensions)
        try super.encode(to: encoder)
    }
    
    // MARK: Assets
    
    override public func imageAssets() -> [ImageValue] {
        super.imageAssets() + [source.assetValue, darkModeSource?.assetValue].compactMap { $0 }
    }
}
