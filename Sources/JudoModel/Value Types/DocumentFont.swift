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

public struct DocumentFont: Codable, Hashable {
    public struct CustomFont: Codable, Hashable {
        public var fontName: FontName
        public var size: CGFloat
        
        public init(fontName: FontName, size: CGFloat) {
            self.fontName = fontName
            self.size = size
        }
    }

    public struct Source: Codable, Hashable {
        public let assetName: String
        public let fontNames: [String]

        public init(assetName: String, fontNames: [String]) {
            self.assetName = assetName
            self.fontNames = fontNames
        }
    }

    public var sources: [Source] // since documentVersion 12
    public var fontFamily: FontFamily
    public var largeTitle: CustomFont
    public var title: CustomFont
    public var title2: CustomFont
    public var title3: CustomFont
    public var headline: CustomFont
    public var body: CustomFont
    public var callout: CustomFont
    public var subheadline: CustomFont
    public var footnote: CustomFont
    public var caption: CustomFont
    public var caption2: CustomFont

    public init(fontFamily: FontFamily, sources: [Source]) {
        self.fontFamily = fontFamily
        self.sources = sources

        let weightMap: [FontWeight: FontName] = fontFamily.names.reduce(into: [:]) { result, fontName in
            if result[fontName.weight] == nil {
                result[fontName.weight] = fontName
            }
        }
        
        let regular = weightMap[.regular] ?? weightMap.first?.value ?? ""
        largeTitle = CustomFont(fontName: regular, size: 34)
        title = CustomFont(fontName: regular, size: 28)
        title2 = CustomFont(fontName: regular, size: 22)
        title3 = CustomFont(fontName: regular, size: 20)
        
        headline = CustomFont(
            fontName: weightMap[.semibold] ?? weightMap[.bold] ?? weightMap[.medium] ?? regular,
            size: 17
        )
        
        body = CustomFont(fontName: regular, size: 17)
        callout = CustomFont(fontName: regular, size: 16)
        subheadline = CustomFont(fontName: regular, size: 15)
        footnote = CustomFont(fontName: regular, size: 13)
        caption = CustomFont(fontName: regular, size: 12)
        caption2 = CustomFont(fontName: regular, size: 11)
    }

    // Decodable

    private enum CodingKeys: String, CodingKey {
        case sources
        case fontFamily
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
        case caption2
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        self.fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)

        if coordinator.documentVersion >= 12 {
            sources = try container.decode([Source].self, forKey: .sources)
        } else {
            sources = coordinator.fonts
                .filter { [fontFamily] in
                    $0.fontFamily == fontFamily
                }.map {
                    Source(assetName: $0.filename, fontNames: $0.fontNames)
                }
        }

        largeTitle = try container.decode(CustomFont.self, forKey: .largeTitle)
        title = try container.decode(CustomFont.self, forKey: .title)
        title2 = try container.decode(CustomFont.self, forKey: .title2)
        title3 = try container.decode(CustomFont.self, forKey: .title3)
        headline = try container.decode(CustomFont.self, forKey: .headline)
        body = try container.decode(CustomFont.self, forKey: .body)
        callout = try container.decode(CustomFont.self, forKey: .callout)
        subheadline = try container.decode(CustomFont.self, forKey: .subheadline)
        footnote = try container.decode(CustomFont.self, forKey: .footnote)
        caption = try container.decode(CustomFont.self, forKey: .caption)
        caption2 = try container.decode(CustomFont.self, forKey: .caption2)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(sources, forKey: .sources)
        try container.encode(fontFamily, forKey: .fontFamily)
        try container.encode(largeTitle, forKey: .largeTitle)
        try container.encode(title, forKey: .title)
        try container.encode(title2, forKey: .title2)
        try container.encode(title3, forKey: .title3)
        try container.encode(headline, forKey: .headline)
        try container.encode(body, forKey: .body)
        try container.encode(callout, forKey: .callout)
        try container.encode(subheadline, forKey: .subheadline)
        try container.encode(footnote, forKey: .footnote)
        try container.encode(caption, forKey: .caption)
        try container.encode(caption2, forKey: .caption2)
    }
}

// MARK: Identifiable

extension DocumentFont: Identifiable {
    public var id: FontFamily {
        fontFamily
    }
}

// MARK: Subscript

extension DocumentFont {
    public subscript(textStyle: FontTextStyle) -> CustomFont {
        get {
            switch textStyle {
            case .largeTitle:
                return largeTitle
            case .title:
                return title
            case .title2:
                return title2
            case .title3:
                return title3
            case .headline:
                return headline
            case .body:
                return body
            case .callout:
                return callout
            case .subheadline:
                return subheadline
            case .footnote:
                return footnote
            case .caption:
                return caption
            case .caption2:
                return caption2
            }
        }
    
        set {
            switch textStyle {
            case .largeTitle:
                largeTitle = newValue
            case .title:
                title = newValue
            case .title2:
                title2 = newValue
            case .title3:
                title3 = newValue
            case .headline:
                headline = newValue
            case .body:
                body = newValue
            case .callout:
                callout = newValue
            case .subheadline:
                subheadline = newValue
            case .footnote:
                footnote = newValue
            case .caption:
                caption = newValue
            case .caption2:
                caption2 = newValue
            }
        }
    }
}

extension DocumentFont {
    public var allNames: Set<String> {
        /// We need to use all the `fontFamily.names` otherwise
        /// we risk missing out some font files if we only use the fonts
        /// used for the semantic fonts. 
        Set(fontFamily.names)
    }
}
