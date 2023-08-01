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
import SwiftUI

public enum Font: Hashable {

    /// A system font with a given semantic style that responds to the Dynamic Type system on iOS and the equivalent on Android.
    case dynamic(textStyle: FontTextStyle, design: FontDesign)

    /// A system font with a fixed size and weight.
    case fixed(size: NumberValue, weight: FontWeight, design: FontDesign)

    /// A font which uses the `CustomFont` value from a `DocumentFont` matching the `fontFamily` and `textStyle`.
    case document(fontFamily: FontFamily, textStyle: FontTextStyle)

    /// A custom font which uses the supplied `FontName` and given `size`.
    case custom(fontName: FontName, size: NumberValue)
}

// MARK: Convenience Initializers

extension Font {
    public static let largeTitle = Font.dynamic(textStyle: .largeTitle, design: .default)
    public static let title = Font.dynamic(textStyle: .title, design: .default)
    @available(iOS 14.0, *)
    public static let title2 = Font.dynamic(textStyle: .title2, design: .default)
    @available(iOS 14.0, *)
    public static let title3 = Font.dynamic(textStyle: .title3, design: .default)
    public static let headline = Font.dynamic(textStyle: .headline, design: .default)
    public static let body = Font.dynamic(textStyle: .body, design: .default)
    public static let callout = Font.dynamic(textStyle: .callout, design: .default)
    public static let subheadline = Font.dynamic(textStyle: .subheadline, design: .default)
    public static let footnote = Font.dynamic(textStyle: .footnote, design: .default)
    public static let caption = Font.dynamic(textStyle: .caption, design: .default)
    @available(iOS 14.0, *)
    public static let caption2 = Font.dynamic(textStyle: .caption2, design: .default)
}

// MARK: Codable

extension Font: Codable {
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case textStyle
        case size
        case weight
        case fontFamily
        case fontName
        case design
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        let caseName = try container.decode(String.self, forKey: .caseName)
        switch caseName {
        case "dynamic":
            let textStyle = try container.decode(FontTextStyle.self, forKey: .textStyle)
            let design = try container.decode(FontDesign.self, forKey: .design)
            self = .dynamic(textStyle: textStyle, design: design)
        case "fixed":
            let weight = try container.decode(FontWeight.self, forKey: .weight)
            let design = try container.decode(FontDesign.self, forKey: .design)

            switch coordinator.documentVersion {
            case ..<16:
                let size = try container.decode(CGFloat.self, forKey: .size)
                self = .fixed(size: NumberValue(size), weight: weight, design: design)
            default:
                let size = try container.decode(NumberValue.self, forKey: .size)
                self = .fixed(size: size, weight: weight, design: design)
            }
        case "document":
            let fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)
            let textStyle = try container.decode(FontTextStyle.self, forKey: .textStyle)
            self = .document(fontFamily: fontFamily, textStyle: textStyle)
        case "custom":
            let fontName = try container.decode(FontName.self, forKey: .fontName)
            switch coordinator.documentVersion {
            case ..<16:
                let size = try container.decode(CGFloat.self, forKey: .size)
                self = .custom(fontName: fontName, size: NumberValue(size))
            default:
                let size = try container.decode(NumberValue.self, forKey: .size)
                self = .custom(fontName: fontName, size: size)
            }

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
        case .dynamic(let textStyle, let design):
            try container.encode("dynamic", forKey: .caseName)
            try container.encode(textStyle, forKey: .textStyle)
            try container.encode(design, forKey: .design)
        case .fixed(let size, let weight, let design):
            try container.encode("fixed", forKey: .caseName)
            try container.encode(size, forKey: .size)
            try container.encode(weight, forKey: .weight)
            try container.encode(design, forKey: .design)
        case .document(let fontFamily, let textStyle):
            try container.encode("document", forKey: .caseName)
            try container.encode(fontFamily, forKey: .fontFamily)
            try container.encode(textStyle, forKey: .textStyle)
        case .custom(let fontName, let size):
            try container.encode("custom", forKey: .caseName)
            try container.encode(fontName, forKey: .fontName)
            try container.encode(size, forKey: .size)
        }
    }
}

extension Font {
    public static func isInstalled(fontName: FontName) -> Bool {
        let fontFamilyDescriptor = CTFontDescriptorCreateWithAttributes(
            [kCTFontNameAttribute: fontName as CFString] as CFDictionary
        )

        let fontCollection = CTFontCollectionCreateWithFontDescriptors(
            [fontFamilyDescriptor] as CFArray, nil
        )

        let fontDescriptors = CTFontCollectionCreateMatchingFontDescriptors(fontCollection) as? [CTFontDescriptor] ?? []
        return !fontDescriptors.isEmpty
    }
}

// MARK: FontFamily

public typealias FontFamily = String

extension FontFamily {
    public static var all: [FontFamily] {
        CTFontManagerCopyAvailableFontFamilyNames() as? [String] ?? []
    }

    public var names: [FontName] {
        let fontFamilyDescriptor = CTFontDescriptorCreateWithAttributes(
            [kCTFontFamilyNameAttribute: self as CFString] as CFDictionary
        )

        let fontCollection = CTFontCollectionCreateWithFontDescriptors(
            [fontFamilyDescriptor] as CFArray, nil
        )

        let fontDescriptors = CTFontCollectionCreateMatchingFontDescriptors(fontCollection) as? [CTFontDescriptor] ?? []

        return fontDescriptors.compactMap {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String
        }
    }
}

// MARK: FontName

public typealias FontName = String

extension FontName {
    public var weight: FontWeight {
        guard let traits = CTFontCopyTraits(font) as? [String: Any],
              let weightTrait = traits[kCTFontWeightTrait as String] as? NSNumber,
              let weightValue = CGFloat(exactly: weightTrait) else {
            assertionFailure("Failed to calculate weight of font with name: \(self)")
            return .regular
        }

        // font weight_map from https://chromium.googlesource.com/chromium/src/+/master/ui/gfx/platform_font_mac.mm#99
        switch weightValue {
        case -1.0 ... -0.70:
            return .ultraLight
        case -0.70 ... -0.45:
            return .thin
        case -0.45 ... -0.10:
            return .light
        case -0.10 ... 0.10:
            return .regular
        case 0.10 ... 0.27:
            return .medium
        case 0.27 ... 0.35:
            return .semibold
        case 0.35 ... 0.50:
            return .bold
        case 0.50 ... 0.60:
            return .heavy
        case 0.60 ... 1.0:
            return .black
        default:
            return .regular
        }
    }

    public var family: FontFamily {
        CTFontCopyFamilyName(font) as String
    }

    public var styleName: String {
        CTFontCopyAttribute(font, kCTFontStyleNameAttribute) as? String ?? self
    }

    public var font: CTFont {
        CTFontCreateWithNameAndOptions(self as CFString, 0, nil, [.preventAutoActivation])
    }
}
