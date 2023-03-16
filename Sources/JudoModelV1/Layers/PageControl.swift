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
import SwiftUI

public class PageControl: Layer {
    override public class var humanName: String {
        "Page Control"
    }
    
    @Dependent public var carousel: Carousel?

    public var style = PageControl.Style.default {
        willSet { objectWillChange.send() }
    }
    
    public var hidesForSinglePage = false { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
        _carousel.publisher = objectWillChange
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
            .accessible,
            .metadatable
        ]
    }

    override public func imageAssets() -> [ImageValue] {
        if case .image(let normalImage, _, let currentImage, _) = style {
            return normalImage.imageAssets() + currentImage.imageAssets()
        }
        return []
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let pageControl = super.copy(with: zone) as! PageControl
        pageControl.hidesForSinglePage = hidesForSinglePage
        pageControl.style = style
        return pageControl
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case style
        case hidesForSinglePage
        case carouselID
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hidesForSinglePage = try container.decode(Bool.self, forKey: .hidesForSinglePage)
        style = try container.decode(PageControl.Style.self, forKey: .style)
        
        if container.contains(.carouselID) {
            let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
            let carouselID = try container.decode(Node.ID.self, forKey: .carouselID)
            coordinator.registerOneToOneRelationship(nodeID: carouselID, to: self, keyPath: \.carousel)
        }
        
        _carousel.publisher = objectWillChange
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hidesForSinglePage, forKey: .hidesForSinglePage)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(carousel?.id, forKey: .carouselID)
        try super.encode(to: encoder)
    }

    public override func colorReferences() -> [Binding<ColorReference>] {
        var references = [Binding<ColorReference>]()

        switch style {
        case let .custom(normalColor: normalColor, currentColor: currentColor):
            references.append(Binding(
                get: { normalColor },
                set: { [weak self] newReference in
                    self?.style = .custom(normalColor: newReference, currentColor: currentColor)
                }
            ))

            references.append(Binding(
                get: { currentColor },
                set: { [weak self] newReference in
                    self?.style = .custom(normalColor: normalColor, currentColor: newReference)
                }
            ))

        case let .image(normalImage: normalImage, normalColor: normalColor, currentImage: currentImage, currentColor: currentColor):
            references.append(Binding(
                get: { normalColor },
                set: { [weak self] newReference in
                    self?.style = .image(normalImage: normalImage, normalColor: newReference, currentImage: currentImage, currentColor: currentColor)
                }
            ))

            references.append(Binding(
                get: { currentColor },
                set: { [weak self] newReference in
                    self?.style = .image(normalImage: normalImage, normalColor: normalColor, currentImage: currentImage, currentColor: newReference)
                }
            ))

        case .dark, .light, .inverted, .`default`:
            break
        }

        return references + super.colorReferences()
    }
}

extension PageControl {
    public enum Style: Codable, Hashable {
        case `default`
        case light
        case dark
        case inverted
        case custom(normalColor: ColorReference, currentColor: ColorReference)
        case image(normalImage: Image, normalColor: ColorReference, currentImage: Image, currentColor: ColorReference)

        // MARK: Codable

        private enum CodingKeys: String, CodingKey {
            case caseName = "__caseName"
            case normalColor
            case currentColor
            case normalImage
            case currentImage
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let caseName = try container.decode(String.self, forKey: .caseName)
            switch caseName {
            case "default":
                self = .default
            case "light":
                self = .light
            case "dark":
                self = .dark
            case "inverted":
                self = .inverted
            case "custom":
                let normalColor = try container.decode(ColorReference.self, forKey: .normalColor)
                let currentColor = try container.decode(ColorReference.self, forKey: .currentColor)
                self = .custom(normalColor: normalColor, currentColor: currentColor)
            case "image":
                let normalColor = try container.decode(ColorReference.self, forKey: .normalColor)
                let currentColor = try container.decode(ColorReference.self, forKey: .currentColor)
                let normalImage = try container.decode(Image.self, forKey: .normalImage)
                let currentImage = try container.decode(Image.self, forKey: .currentImage)
                self = .image(normalImage: normalImage, normalColor: normalColor, currentImage: currentImage, currentColor: currentColor)
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
            case .`default`:
                try container.encode("default", forKey: .caseName)
            case .light:
                try container.encode("light", forKey: .caseName)
            case .dark:
                try container.encode("dark", forKey: .caseName)
            case .inverted:
                try container.encode("inverted", forKey: .caseName)
            case .custom(let normalColor, let currentColor):
                try container.encode("custom", forKey: .caseName)
                try container.encode(normalColor, forKey: .normalColor)
                try container.encode(currentColor, forKey: .currentColor)
            case .image(let normalImage, let normalColor, let currentImage, let currentColor):
                try container.encode("image", forKey: .caseName)
                try container.encode(normalImage, forKey: .normalImage)
                try container.encode(currentImage, forKey: .currentImage)
                try container.encode(normalColor, forKey: .normalColor)
                try container.encode(currentColor, forKey: .currentColor)
            }
        }
    }
}
