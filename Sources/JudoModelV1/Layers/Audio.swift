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

public final class Audio: Layer {
    public var source: AssetSource<MediaValue> { willSet { objectWillChange.send() }}
    public var autoPlay = false { willSet { objectWillChange.send() } }
    public var looping = false { willSet { objectWillChange.send() } }
    
    public init(audio: MediaValue) {
        self.source = .fromFile(value: audio)
        super.init()
    }
    
    public init(url: String) {
        source = .fromURL(url: url)
        super.init()
    }
    
    required public init() {
        source = .audioPlaceholder
        super.init()
    }
    
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
            .accessible,
            .metadatable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let audio = super.copy(with: zone) as! Audio
        audio.source = source
        audio.autoPlay = autoPlay
        audio.looping = looping
        return audio
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case source
        case autoPlay
        case looping
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.source = try container.decode(AssetSource.self, forKey: .source)
        self.autoPlay = try container.decode(Bool.self, forKey: .autoPlay)
        self.looping = try container.decode(Bool.self, forKey: .looping)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(source, forKey: .source)
        try container.encode(autoPlay, forKey: .autoPlay)
        try container.encode(looping, forKey: .looping)
        try super.encode(to: encoder)
        
    }
    
    // MARK: Assets
    
    override public func mediaAssets() -> [MediaValue] {
        super.mediaAssets() + [source.assetValue].compactMap { $0 }
    }
}
