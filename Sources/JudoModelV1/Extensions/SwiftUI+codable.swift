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

// MARK: Axis

public enum Axis: String, Codable {
    case horizontal
    case vertical

    public var swiftUIValue: SwiftUI.Axis {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}

// MARK: ContentSizeCategory

public enum ContentSizeCategory: Codable {
    case accessibilityExtraExtraExtraLarge
    case accessibilityExtraExtraLarge
    case accessibilityExtraLarge
    case accessibilityLarge
    case accessibilityMedium
    case extraExtraExtraLarge
    case extraExtraLarge
    case extraLarge
    case extraSmall
    case large
    case medium
    case small

    public var swiftUIValue: SwiftUI.ContentSizeCategory {
        switch self {
        case .accessibilityExtraExtraExtraLarge:
            return .accessibilityExtraExtraExtraLarge
        case .accessibilityExtraExtraLarge:
            return .accessibilityExtraExtraLarge
        case .accessibilityExtraLarge:
            return .accessibilityExtraLarge
        case .accessibilityLarge:
            return .accessibilityLarge
        case .accessibilityMedium:
            return .accessibilityMedium
        case .extraExtraExtraLarge:
            return .extraExtraExtraLarge
        case .extraExtraLarge:
            return .extraExtraLarge
        case .extraLarge:
            return .extraLarge
        case .extraSmall:
            return .extraSmall
        case .large:
            return .large
        case .medium:
            return .medium
        case .small:
            return .small
        }
    }
}

extension ContentSizeCategory: RawRepresentable {
    public static let `default` = ContentSizeCategory.large

    public init?(rawValue: String) {
        switch rawValue {
            case "accessibilityExtraExtraExtraLarge":
                self = .accessibilityExtraExtraExtraLarge
            case "accessibilityExtraExtraLarge":
                self = .accessibilityExtraExtraLarge
            case "accessibilityExtraLarge":
                self = .accessibilityExtraLarge
            case "accessibilityLarge":
                self = .accessibilityLarge
            case "accessibilityMedium":
                self = .accessibilityMedium
            case "extraExtraExtraLarge":
                self = .extraExtraExtraLarge
            case "extraExtraLarge":
                self = .extraExtraLarge
            case "extraLarge":
                self = .extraLarge
            case "extraSmall":
                self = .extraSmall
            case "large":
                self = .large
            case "medium":
                self = .medium
            case "small":
                self = .small
            default:
                return nil
        }
    }

    public var rawValue: String {
        switch self {
            case .accessibilityExtraExtraExtraLarge:
                return "accessibilityExtraExtraExtraLarge"
            case .accessibilityExtraExtraLarge:
                return "accessibilityExtraExtraLarge"
            case .accessibilityExtraLarge:
                return "accessibilityExtraLarge"
            case .accessibilityLarge:
                return "accessibilityLarge"
            case .accessibilityMedium:
                return "accessibilityMedium"
            case .extraExtraExtraLarge:
                return "extraExtraExtraLarge"
            case .extraExtraLarge:
                return "extraExtraLarge"
            case .extraLarge:
                return "extraLarge"
            case .extraSmall:
                return "extraSmall"
            case .large:
                return "large"
            case .medium:
                return "medium"
            case .small:
                return "small"
        }
    }
}

extension ContentSizeCategory: CustomStringConvertible {
    public var description: String {
        switch self {
            case .accessibilityExtraExtraExtraLarge:
                return "Accessibility XXX Large"
            case .accessibilityExtraExtraLarge:
                return "Accessibility XX Large"
            case .accessibilityExtraLarge:
                return "Accessibility Extra Large"
            case .accessibilityLarge:
                return "Accessibility Large"
            case .accessibilityMedium:
                return "Accessibility Medium"
            case .extraExtraExtraLarge:
                return "XXX Large"
            case .extraExtraLarge:
                return "XX Large"
            case .extraLarge:
                return "Extra Large"
            case .extraSmall:
                return "Extra Small"
            case .large:
                return "Large (Default)"
            case .medium:
                return "Medium"
            case .small:
                return "Small"
        }
    }
}


// MARK: TextAlignment

public enum TextAlignment: String, CaseIterable, Codable, Identifiable {
    case leading
    case center
    case trailing

    public var swiftUIValue: SwiftUI.TextAlignment {
        switch self {
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }

    public var id: String {
        self.rawValue
    }
}

// MARK: HorizontalAlignment

public enum HorizontalAlignment: String, CaseIterable, Codable, Identifiable, Equatable {
    case center
    case leading
    case trailing

    public var swiftUIValue: SwiftUI.HorizontalAlignment {
        switch self {
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }

    public var id: String {
        self.rawValue
    }

    public static var allCases: [HorizontalAlignment] {
        [.leading, .center, .trailing]
    }
}

extension HorizontalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .center:
            return "Center"
        case .leading:
            return "Leading"
        case .trailing:
            return "Trailing"
        }
    }
}

extension HorizontalAlignment: Hashable {
    
}

extension HorizontalAlignment: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "center":
            self = .center
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .center:
            return "center"
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        }
    }
}

extension HorizontalAlignment {
    public var symbolName: String {
        switch self {
        case .leading:
            return "arrow.left.to.line"
        case .center:
            return  "text.aligncenter"
        case .trailing:
            return "arrow.right.to.line"
        }
    }
}

// MARK: VerticalAlignment

public enum VerticalAlignment: String, Codable, Equatable {
    case top
    case center
    case bottom
    case firstTextBaseline

    public var swiftUIValue: SwiftUI.VerticalAlignment {
        switch self {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        case .firstTextBaseline:
            return .firstTextBaseline
        }
    }
}

extension VerticalAlignment: CaseIterable {
    public static var allCases: [VerticalAlignment] {
        [.top, .center, .bottom, .firstTextBaseline]
    }
}

extension VerticalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bottom:
            return "Bottom"
        case .center:
            return "Center"
        case .firstTextBaseline:
            return "Baseline"
        case .top:
            return "Top"
        }
    }
}

extension VerticalAlignment: Hashable {
    
}

extension VerticalAlignment: Identifiable {
    public var id: String {
        rawValue
    }
}

extension VerticalAlignment: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "bottom":
            self = .bottom
        case "center":
            self = .center
        case "baseline":
            self = .firstTextBaseline
        case "top":
            self = .top
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .bottom:
            return "bottom"
        case .center:
            return "center"
        case .firstTextBaseline:
            return "baseline"
        case .top:
            return "top"
        }
    }
}

extension VerticalAlignment {
    public var symbolName: String {
        switch self {
        case .top:
            return "arrow.up.to.line"
        case .center:
            return "text.aligncenter"
        case .bottom:
            return "arrow.down.to.line"
        case .firstTextBaseline:
            return "textformat.abc.dottedunderline"
        }
    }
}

// MARK: Alignment

public struct Alignment {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment

    public static let topLeading: Alignment = .init(horizontal: .leading, vertical: .top)
    public static let top: Alignment = .init(horizontal: .center, vertical: .top)
    public static let topTrailing: Alignment = .init(horizontal: .trailing, vertical: .top)

    public static let leading: Alignment = .init(horizontal: .leading, vertical: .center)
    public static let center: Alignment = .init(horizontal: .center, vertical: .center)
    public static let trailing: Alignment = .init(horizontal: .trailing, vertical: .center)

    public static let bottomLeading: Alignment = .init(horizontal: .leading, vertical: .bottom)
    public static let bottom: Alignment = .init(horizontal: .center, vertical: .bottom)
    public static let bottomTrailing: Alignment = .init(horizontal: .trailing, vertical: .bottom)

    public var swiftUIValue: SwiftUI.Alignment {
        switch self {
        case .topLeading:
            return .topLeading
        case .top:
            return .top
        case .topTrailing:
            return .topTrailing
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .bottomLeading:
            return .bottomLeading
        case .bottom:
            return .bottom
        case .bottomTrailing:
            return .bottomTrailing
        default:
            fatalError("Unknown Alignment")
        }
    }
}

extension Alignment: CaseIterable {
    public static var allCases: [Alignment] {
        [
            .bottom,
            .bottomLeading,
            .bottomTrailing,
            .center,
            .leading,
            .top,
            .topLeading,
            .topTrailing,
            .trailing
        ]
    }
}

extension Alignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bottom:
            return "Bottom"
        case .bottomLeading:
            return "Bottom Leading"
        case .bottomTrailing:
            return "Bottom Trailing"
        case .center:
            return "Center"
        case .leading:
            return "Leading"
        case .top:
            return "Top"
        case .topLeading:
            return "Top Leading"
        case .topTrailing:
            return "Top Trailing"
        case .trailing:
            return "Trailing"
        default:
            fatalError()
        }
    }
}

extension Alignment: Hashable {
    
}

extension Alignment: Identifiable {
    public var id: String {
        rawValue
    }
}

extension Alignment {

    public init?(rawValue: String) {
        switch rawValue {
        case "bottom":
            self = .bottom
        case "bottomLeading":
            self = .bottomLeading
        case "bottomTrailing":
            self = .bottomTrailing
        case "center":
            self = .center
        case "leading":
            self = .leading
        case "top":
            self = .top
        case "topLeading":
            self = .topLeading
        case "topTrailing":
            self = .topTrailing
        case "trailing":
            self = .trailing
        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .bottom:
            return "bottom"
        case .bottomLeading:
            return "bottomLeading"
        case .bottomTrailing:
            return "bottomTrailing"
        case .center:
            return "center"
        case .leading:
            return "leading"
        case .top:
            return "top"
        case .topLeading:
            return "topLeading"
        case .topTrailing:
            return "topTrailing"
        case .trailing:
            return "trailing"
        default:
            fatalError()
        }
    }
}

extension Alignment: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard Alignment(rawValue: rawValue) != nil else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value: \(rawValue)"
            )
        }

        self.init(rawValue: rawValue)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: Edge

public enum Edge: String, Codable {
    case top
    case leading
    case bottom
    case trailing

    public var swiftUIValue: SwiftUI.Edge {
        switch self {
        case .top:
            return .top
        case .leading:
            return .leading
        case .bottom:
            return .bottom
        case .trailing:
            return .trailing
        }
    }
}

// MARK: SwiftUI.Font.TextStyle

public enum FontTextStyle: String, CaseIterable {
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

    @available(iOS 13.0, *)
    public var swiftUIValue: SwiftUI.Font.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .title2:
            if #available(iOS 14.0, *) {
                return .title2
            } else {
                return .title
            }
        case .title3:
            if #available(iOS 14.0, *) {
                return .title3
            } else {
                return .title
            }
        case .headline:
            return .headline
        case .body:
            return .body
        case .callout:
            return .callout
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        case .caption2:
            if #available(iOS 14.0, *) {
                return .caption2
            } else {
                return .caption
            }
        }
    }
}

extension FontTextStyle: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "largeTitle":
            self = .largeTitle
        case "title":
            self = .title
        case "title2":
            self = .title2
        case "title3":
            self = .title3
        case "headline":
            self = .headline
        case "body":
            self = .body
        case "callout":
            self = .callout
        case "subheadline":
            self = .subheadline
        case "footnote":
            self = .footnote
        case "caption":
            self = .caption
        case "caption2":
            self = .caption2
        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .largeTitle:
            return "largeTitle"
        case .title:
            return "title"
        case .title2:
            return "title2"
        case .title3:
            return "title3"
        case .headline:
            return "headline"
        case .body:
            return "body"
        case .callout:
            return "callout"
        case .subheadline:
            return "subheadline"
        case .footnote:
            return "footnote"
        case .caption:
            return "caption"
        case .caption2:
            return "caption2"
        }
    }
}

extension FontTextStyle: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        if let textStyle = FontTextStyle(rawValue: value) {
            self = textStyle
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value: \(value.self)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if !rawValue.isEmpty {
            try container.encode(rawValue)
        } else {
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid value: \(self)"
                )
            )
        }
    }
}

// MARK: SwiftUI.Font.Weight

public enum FontWeight {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    public var swiftUIValue: SwiftUI.Font.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }
}

extension FontWeight: RawRepresentable {
    public init?(rawValue: String) {
        switch rawValue {
        case "ultraLight":
            self = .ultraLight
        case "thin":
            self = .thin
        case "light":
            self = .light
        case "regular":
            self = .regular
        case "medium":
            self = .medium
        case "semibold":
            self = .semibold
        case "bold":
            self = .bold
        case "heavy":
            self = .heavy
        case "black":
            self = .black
        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .ultraLight:
            return "ultraLight"
        case .thin:
            return "thin"
        case .light:
            return "light"
        case .regular:
            return "regular"
        case .medium:
            return "medium"
        case .semibold:
            return "semibold"
        case .bold:
            return "bold"
        case .heavy:
            return "heavy"
        case .black:
            return "black"
        }
    }
}

extension FontWeight: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        if let weight = FontWeight(rawValue: value) {
            self = weight
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value: \(value.self)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if !rawValue.isEmpty {
            try container.encode(rawValue)
        } else {
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid value: \(self)"
                )
            )
        }
    }
}
