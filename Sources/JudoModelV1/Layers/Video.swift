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
import CoreGraphics
import os.log

public final class Video: Layer {
    public enum ResizingMode: String, Codable {
        case scaleToFit
        case scaleToFill
    }
    
    public var source: AssetSource<MediaValue> { willSet { objectWillChange.send() } }
    public var resizingMode = ResizingMode.scaleToFit { willSet { objectWillChange.send() } }
    public var poster: ImageValue? { willSet { objectWillChange.send() } }
    public var showControls = true { willSet { objectWillChange.send() } }
    public var autoPlay = false { willSet { objectWillChange.send() } }
    public var removeAudio = false { willSet { objectWillChange.send() } }
    public var looping = false { willSet { objectWillChange.send() } }
    
    public init(video: MediaValue) {
        source = .fromFile(value: video)
        poster = video.generatePoster()
        super.init()
    }
    
    public init(url: String) {
        source = .fromURL(url: url)
        super.init()
    }
    
    required public init() {
        source = .videoPlaceholder
        showControls = false
        autoPlay = true
        looping = true
        super.init()
        aspectRatio = CGFloat(16) / CGFloat(9)
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
        let video = super.copy(with: zone) as! Video
        video.source = source
        video.resizingMode = resizingMode
        video.poster = poster
        video.autoPlay = autoPlay
        video.showControls = showControls
        video.removeAudio = removeAudio
        video.looping = looping
        return video
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case resizingMode
        case source
        case posterImageName
        case showControls
        case autoPlay
        case removeAudio
        case looping
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        self.resizingMode = try container.decode(ResizingMode.self, forKey: .resizingMode)
        self.source = try container.decode(AssetSource.self, forKey: .source)
        self.showControls = try container.decode(Bool.self, forKey: .showControls)
        self.autoPlay = try container.decode(Bool.self, forKey: .autoPlay)
        self.removeAudio = try container.decode(Bool.self, forKey: .removeAudio)
        self.looping = try container.decode(Bool.self, forKey: .looping)
        if let posterImageName = try container.decodeIfPresent(String.self, forKey: .posterImageName) {
            guard let posterImage = coordinator.imageByFilename(posterImageName) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .posterImageName,
                    in: container,
                    debugDescription: "Image for video poster missing from document bundle: \(posterImageName)"
                )
            }
            
            self.poster = posterImage
        }
        
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(source, forKey: .source)
        try container.encode(resizingMode, forKey: .resizingMode)
        try container.encodeIfPresent(poster?.filename, forKey: .posterImageName)
        try container.encode(showControls, forKey: .showControls)
        try container.encode(autoPlay, forKey: .autoPlay)
        try container.encode(removeAudio, forKey: .removeAudio)
        try container.encode(looping, forKey: .looping)
        try super.encode(to: encoder)
    }
    
    // MARK: Assets
    
    override public func mediaAssets() -> [MediaValue] {
        super.mediaAssets() + [source.assetValue].compactMap { $0 }
    }
    
    override public func imageAssets() -> [ImageValue] {
        super.imageAssets() + [poster].compactMap { $0 }
    }
}
