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

#if canImport(UIKit)
import UIKit
#endif

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

    public static let firstTextBaselineLeading: Alignment = .init(horizontal: .leading, vertical: .firstTextBaseline)
    public static let firstTextBaseline: Alignment = .init(horizontal: .center, vertical: .firstTextBaseline)
    public static let firstTextBaselineTrailing: Alignment = .init(horizontal: .trailing, vertical: .firstTextBaseline)

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
        case .firstTextBaselineLeading:
            return .leadingFirstTextBaseline
        case .firstTextBaseline:
            return .centerFirstTextBaseline
        case .firstTextBaselineTrailing:
            return .trailingFirstTextBaseline
        default:
            fatalError("Unknown Alignment \(self)")
        }
    }
}

extension Alignment: CaseIterable {
    public static var allCases: [Alignment] {
        [
            .firstTextBaseline,
            .firstTextBaselineLeading,
            .firstTextBaselineTrailing,
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
        case .firstTextBaseline:
            return "First Text Baseline"
        case .firstTextBaselineLeading:
            return "First Text Baseline Leading"
        case .firstTextBaselineTrailing:
            return "First Text Baseline Trailing"
        default:
            fatalError("unknown alignment")
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
        case "firstTextBaseline":
            self = .firstTextBaseline
        case "firstTextBaselineLeading":
            self = .firstTextBaselineLeading
        case "firstTextBaselineTrailing":
            self = .firstTextBaselineTrailing
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
        case .firstTextBaseline:
            return "firstTextBaseLine"
        case .firstTextBaselineLeading:
            return "firstTextBaselineLeading"
        case .firstTextBaselineTrailing:
            return "firstTextBaselineTrailing"
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

public enum TextCase: String, Codable {
    case uppercase
    case lowercase

    public var swiftUIValue: SwiftUI.Text.Case {
        switch self {
        case .uppercase:
            return .uppercase
        case .lowercase:
            return .lowercase
        }
    }
}

public enum FontDesign: String, Codable {
    case `default`
    case monospaced
    case rounded
    case serif

    public var swiftUIValue: SwiftUI.Font.Design {
        switch self {
        case .default:
            return .default
        case .monospaced:
            return .monospaced
        case .rounded:
            return .rounded
        case .serif:
            return .serif
        }
    }
}

public enum TabViewStyle: Codable {
    case automatic
    case page(indexDisplayMode: TabViewStyle.IndexDisplayMode)

    public enum IndexDisplayMode: Codable, CaseIterable, CustomStringConvertible, Identifiable {
        // Always display an index view (page indicator dots) regardless of page count
        case always

        // Displays an index view when there are more than one page. This is the default setting.
        case automatic

        // Never display an index view
        case never

        public var id: Self {
            self
        }

        public var description: String {
            switch self {
            case .always:
                return "Always"
            case .automatic:
                return "Automatic"
            case .never:
                return "Never"
            }
        }
    }
}


public enum IndexViewStyle: Codable {
    case page(backgroundDisplayMode: IndexViewStyle.BackgroundDisplayMode)

    public enum BackgroundDisplayMode: Codable, CaseIterable, CustomStringConvertible, Identifiable {
        // The OS will determine when to show the background. This is the default setting.
        case automatic

        // Background is always displayed behind the dots.
        case always

        // Background is only shown while when the user long presses on the dots. This seems to be the default.
        case interactive

        // Background is never displayed.
        case never

        public var id: Self {
            self
        }

        public var description: String {
            switch self {
            case .automatic:
                return "Automatic"
            case .always:
                return "Always"
            case .interactive:
                return "Interactive"
            case .never:
                return "Never"
            }
        }
    }
}


public enum TitleDisplayMode: Codable, CaseIterable, CustomStringConvertible, Identifiable {
    case automatic
    case inline
    case large

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .inline:
            return "Inline"
        case .large:
            return "Large"
        }
    }
}


public enum Visibility: Codable, CaseIterable, CustomStringConvertible, Identifiable {
    // The background is visible when a scroll view's content is beneath it.
    case automatic

    // Background is always visible.
    case visible

    // Background is never visible
    case hidden

    public var id: Self {
        self
    }


    public var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .visible:
            return "Visible"
        case .hidden:
            return "Hidden"
        }
    }
}


public enum ColorScheme: Codable, CaseIterable, CustomStringConvertible, Identifiable {
    case dark
    case light

    public var swiftUIValue: SwiftUI.ColorScheme {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}


public struct ToolbarPlacement: OptionSet, Codable {
    public static let navigationBar = ToolbarPlacement(rawValue: 1 << 0)
    public static let tabBar = ToolbarPlacement(rawValue: 1 << 1)
    
    public static let none: ToolbarPlacement = []
    public static let all: ToolbarPlacement = [.navigationBar, .tabBar]
    
    // On iOS, automatic is equivalent to navigationBar
    public static let automatic: ToolbarPlacement = [.navigationBar]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }


}

// MARK: - Button Style

public enum ButtonStyle: Codable, CaseIterable, CustomStringConvertible, Identifiable {
    /// Same as Borderless
    case automatic

    /// Default style
    /// Doesn't apply a border
    /// Text, shapes, and images (with rendering mode set to template) are tinted with the current tint colour
    case borderless

    /// Wraps the content in 12 points of horizontal padding and 7 points of vertical padding
    /// Adds a rounded rectangle background filled with `.secondaryFill` color and 7 points of corner radius
    /// Text, shapes, and images (with rendering mode set to template) are tinted with the current tint colour
    case bordered

    /// Wraps the content in 12 points of horizontal padding and 7 points of vertical padding
    /// Adds a rounded rectangle background filled with accent color and 7 points of corner radius
    /// Text, shapes, and images (with rendering mode set to template) are tinted white
    case borderedProminent

    /// Applies no visual changed to the content wrapped by the button
    case plain

    public var swiftUIValue: any SwiftUI.PrimitiveButtonStyle {
        switch self {
        case .automatic:
            return .automatic
        case .plain:
            return .plain
        case .borderless:
            return .borderless
        case .bordered:
            if #available(iOS 15.0, *) {
                return .bordered
            } else {
                return .automatic
            }
        case .borderedProminent:
            if #available(iOS 15.0, macOS 12.0, *) {
                return .borderedProminent
            } else {
                return .automatic
            }
        }
    }

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .borderless:
            return "Borderless"
        case .bordered:
            return "Bordered"
        case .borderedProminent:
            return "Prominent"
        case .plain:
            return "Plain"
        }
    }
}

// MARK: - Content Mode

public enum ContentMode: Codable, CaseIterable, CustomStringConvertible, Identifiable {
    case fill
    case fit

    public var description: String {
        switch self {
        case .fill:
            return "Fill"
        case .fit:
            return "Fit"
        }
    }
    
    public var id: Self {
        self
    }

    public var swiftUIValue: SwiftUI.ContentMode {
        switch self {
        case .fill:
            return .fill
        case .fit:
            return .fit
        }
    }
}

// MARK: - Axes

public struct Axes: OptionSet, Codable, Hashable {
    public static let vertical = Axes(rawValue: 1 << 0)
    public static let horizontal = Axes(rawValue: 1 << 1)
    
    public static let none: Axes = []
    public static let all: Axes = [.vertical, .horizontal]
    
    public static let automatic: Axes = [.vertical]
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var swiftUIValue: SwiftUI.Axis.Set {
        var result = SwiftUI.Axis.Set()
        
        if self.contains(.vertical) {
            result.insert(.vertical)
        }
        
        if self.contains(.horizontal) {
            result.insert(.horizontal)
        }
        
        return result
    }
}

// MARK: - ToolbarItemPlacement

public enum ToolbarItemPlacement: Codable, CaseIterable, CustomStringConvertible, Hashable, Identifiable {
    /// Trailing edge of navigation bar.
    case automatic

    /// Trailing edge of navigation bar.
    case trailing

    /// Leading edge of navigation bar.
    case leading

    /// Leading edge of navigation bar.
    case cancellation

    /// Trailing edge of navigation bar.
    case confirmation

    /// Trailing edge of navigation bar.
    case destruction

    /// Leading edge of navigation bar. On iPhone, if there is a back button displayed, it is instead displayed on the trailing edge.
    case navigation

    /// Trailing edge of navigation bar.
    case primary

    /// Displays a ellipsis.circle icon on the trailing edge of the navigation bar which opens a context menu containing all toolbar items with the `.secondaryAction`.
    /// It is always the right-most (left-most for a RTL language) item in the group of trailing items.
    case secondary

    /// The center of the navigation bar, takes precedent over a title specified through the .`navigationTitle` modifier.
    case principal

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .trailing:
            return "Trailing"
        case .leading:
            return "Leading"
        case .cancellation:
            return "Cancellation"
        case .confirmation:
            return "Confirmation"
        case .destruction:
            return "Destruction"
        case .navigation:
            return "Navigation"
        case .primary:
            return "Primary"
        case .secondary:
            return "Secondary"
        case .principal:
            return "Principal"
        }
    }
}


// MARK: - ButtonRole

public enum ButtonRole: CaseIterable, Codable, CustomStringConvertible, Hashable, Identifiable {
    case `none`
    case cancel
    case destructive

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .none:
            return "None"
        case .cancel:
            return "Cancel"
        case .destructive:
            return "Destructive"
        }
    }

    @available(iOS 15.0, macOS 12.0, *)
    public var swiftUIValue: SwiftUI.ButtonRole? {
        switch self {
        case .none:
            return .none
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

// MARK: - AccessibilityChildBehavior

public enum AccessibilityChildBehavior: Codable, CaseIterable, CustomStringConvertible,  Hashable, Identifiable {
    case combine
    case contain
    case ignore

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .combine:
            return "Combine"
        case .contain:
            return "Contain"
        case .ignore:
            return "Ignore"
        }
    }

    public var swiftUIValue: SwiftUI.AccessibilityChildBehavior {
        switch self {
        case .combine:
            return .combine
        case .contain:
            return .contain
        case .ignore:
            return .ignore
        }
    }
}

// MARK: - AccessibilityTraits

public struct AccessibilityTraits: OptionSet, Codable, Hashable {
    public static let isButton = AccessibilityTraits(rawValue: 1 << 0)
    public static let isHeader = AccessibilityTraits(rawValue: 1 << 1)
    public static let isLink = AccessibilityTraits(rawValue: 1 << 2)
    public static let isModal = AccessibilityTraits(rawValue: 1 << 3)
    public static let isSummaryElement = AccessibilityTraits(rawValue: 1 << 4)
    public static let startsMediaSession = AccessibilityTraits(rawValue: 1 << 5)

    public static let none: AccessibilityTraits = []
    public static let all: AccessibilityTraits = [.isButton, .isHeader, .isLink, .isModal, .isSummaryElement, .startsMediaSession]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: SymbolRenderingMode

public enum SymbolRenderingMode: Identifiable, CaseIterable, Codable, CustomStringConvertible {
    case hierarchical
    case monochrome
    case multicolor
    // Commented out for https://github.com/judoapp/judo-app/issues/2280
    //    case palette

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .hierarchical:
            return "Hierarchical"
        case .monochrome:
            return "Monochrome"
        case .multicolor:
            return "MultiColor"
            // Commented out for https://github.com/judoapp/judo-app/issues/2280
            //        case .palette:
            //            return "Palette"
        }
    }

    @available(iOS 15.0, macOS 12.0, *)
    public var swiftUIValue: SwiftUI.SymbolRenderingMode {
        switch self {
        case .hierarchical:
            return .hierarchical
        case .monochrome:
            return .monochrome
        case .multicolor:
            return .multicolor
            // Commented out for https://github.com/judoapp/judo-app/issues/2280
            //        case .palette:
            //            return .palette
        }
    }
}

// MARK: - ResizingMode

public enum ResizingMode: Identifiable, CaseIterable, Codable, CustomStringConvertible {
    case `none`
    case stretch
    case tile

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .none:
            return "None"
        case .stretch:
            return "Stretch"
        case .tile:
            return "Tile"
        }
    }

    public var swiftUIValue: SwiftUI.Image.ResizingMode {
        switch self {
        case .none:
            fatalError("No value .none on SwiftUI.Image.ResizingMode")
        case .stretch:
            return .stretch
        case .tile:
            return .tile
        }
    }
}


// MARK: - TemplateRenderingMode

/// A type that indicates how framework renders images.
public enum TemplateRenderingMode: Identifiable, CaseIterable, Codable, CustomStringConvertible {
    case original
    case template

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .original:
            return "Original"
        case .template:
            return "Template"
        }
    }
}

// MARK: - UITextContentType

public enum TextContentType: Identifiable, CaseIterable, Codable, CustomStringConvertible {

    // Identifying Contacts
    case name
    case namePrefix
    case givenName
    case middleName
    case familyName
    case nameSuffix
    case nickname
    case jobTitle
    case organizationName

    // Setting Location Data
    case location
    case fullStreetAddress
    case streetAddressLine1
    case streetAddressLine2
    case addressCity
    case addressCityAndState
    case addressState
    case postalCode
    case sublocality
    case countryName


    // Setting Communication Details
    case telephoneNumber
    case emailAddress

    // Defining Web Addresses
    case URL

    // Accepting Payment
    case creditCardNumber

    // Managing Accounts
    case username
    case password
    case newPassword

    // Securing Accounts
    case oneTimeCode

    // Tracking Events
    case shipmentTrackingNumber
    case flightNumber

    // Scheduling Events
    case dateTime

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .URL:
            return "URL"
        case .namePrefix:
            return "Name Prefix"
        case .name:
            return "Name"
        case .nameSuffix:
            return "Name Suffix"
        case .givenName:
            return "Given Name"
        case .middleName:
            return "Middle Name"
        case .familyName:
            return "Family Name"
        case .nickname:
            return "Nickname"
        case .organizationName:
            return "Organization Name"
        case .jobTitle:
            return "Job Title"
        case .location:
            return "Location"
        case .fullStreetAddress:
            return "Full Street Address"
        case .streetAddressLine1:
            return "Street Address Line 1"
        case .streetAddressLine2:
            return "Street Address Line 2"
        case .addressCity:
            return "Address City"
        case .addressCityAndState:
            return "Address City And State"
        case .addressState:
            return "Address State"
        case .postalCode:
            return "Postal Code"
        case .sublocality:
            return "Sublocality"
        case .countryName:
            return "Country Name"
        case .username:
            return "Username"
        case .password:
            return "Password"
        case .newPassword:
            return "New Password"
        case .oneTimeCode:
            return "One Time Code"
        case .emailAddress:
            return "Email Address"
        case .telephoneNumber:
            return "Telephone Number"
        case .creditCardNumber:
            return "Credit Card Number"
        case .dateTime:
            return "Date Time"
        case .flightNumber:
            return "Flight Number"
        case .shipmentTrackingNumber:
            return "Shipment Tracking Number"
        }
    }

#if canImport(UIKit)
    public var uiKitValue: UIKit.UITextContentType? {
        switch self {
        case .URL:
            return .URL
        case .namePrefix:
            return .namePrefix
        case .name:
            return .name
        case .nameSuffix:
            return .nameSuffix
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .familyName:
            return .familyName
        case .nickname:
            return .nickname
        case .organizationName:
            return .organizationName
        case .jobTitle:
            return .jobTitle
        case .location:
            return .location
        case .fullStreetAddress:
            return .fullStreetAddress
        case .streetAddressLine1:
            return .streetAddressLine1
        case .streetAddressLine2:
            return .streetAddressLine2
        case .addressCity:
            return .addressCity
        case .addressCityAndState:
            return .addressCityAndState
        case .addressState:
            return .addressState
        case .postalCode:
            return .postalCode
        case .sublocality:
            return .sublocality
        case .countryName:
            return .countryName
        case .username:
            return .username
        case .password:
            return .password
        case .newPassword:
            return .newPassword
        case .oneTimeCode:
            return .oneTimeCode
        case .emailAddress:
            return .emailAddress
        case .telephoneNumber:
            return .telephoneNumber
        case .creditCardNumber:
            return .creditCardNumber
        case .dateTime:
            if #available(iOS 15, *) {
                return .dateTime
            } else {
                return nil
            }
        case .flightNumber:
            if #available(iOS 15, *) {
                return .flightNumber
            } else {
                return nil
            }
        case .shipmentTrackingNumber:
            if #available(iOS 15, *) {
                return .shipmentTrackingNumber
            } else {
                return nil
            }
        }
    }
#endif
}


// MARK: - UITextAutocapitalizationType

@available(iOS, deprecated: 15.0, message: "We should update this as `.autocapitalization` is is deprecated in favor of `.textInputAutocapitalization`")
public enum TextAutocapitalizationType: Identifiable, CaseIterable, Codable, CustomStringConvertible {

    case none
    case words
    case sentences
    case allCharacters

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .none:
            return "None"
        case .words:
            return "Words"
        case .sentences:
            return "Sentences"
        case .allCharacters:
            return "All Characters"
        }
    }

#if canImport(UIKit)
    public var uiKitValue: UIKit.UITextAutocapitalizationType {
        switch self {
        case .none:
            return .none
        case .words:
            return .words
        case .sentences:
            return .sentences
        case .allCharacters:
            return .allCharacters
        }
    }
#endif
}


// MARK: - UIKeyboardType

public enum KeyboardType: Identifiable, CaseIterable, Codable, CustomStringConvertible {

    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
    case alphabet


    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .default:
            return "Default"
        case .asciiCapable:
            return "Ascii Capable"
        case .numbersAndPunctuation:
            return "Numbers And Punctuation"
        case .URL:
            return "URL"
        case .numberPad:
            return "Number Pad"
        case .phonePad:
            return "Phone Pad"
        case .namePhonePad:
            return "Name Phone Pad"
        case .emailAddress:
            return "Email Address"
        case .decimalPad:
            return "Decimal Pad"
        case .twitter:
            return "Twitter"
        case .webSearch:
            return "Web Search"
        case .asciiCapableNumberPad:
            return "Ascii Capable Number Pad"
        case .alphabet:
            return "Alphabet"
        }
    }

#if canImport(UIKit)
    public var uiKitValue: UIKit.UIKeyboardType {
        switch self {
        case .default:
            return .default
        case .asciiCapable:
            return .asciiCapable
        case .numbersAndPunctuation:
            return .numbersAndPunctuation
        case .URL:
            return .URL
        case .numberPad:
            return .numberPad
        case .phonePad:
            return .phonePad
        case .namePhonePad:
            return .namePhonePad
        case .emailAddress:
            return .emailAddress
        case .decimalPad:
            return .decimalPad
        case .twitter:
            return .twitter
        case .webSearch:
            return .webSearch
        case .asciiCapableNumberPad:
            return .asciiCapableNumberPad
        case .alphabet:
            return .alphabet
        }
    }
#endif
}


// MARK: - SubmitLabel

public enum SubmitLabel: Identifiable, CaseIterable, Codable, CustomStringConvertible {
    case done
    case go
    case send
    case join
    case route
    case search
    case `return`
    case next
    case `continue`

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .continue:
            return "Continue"
        case .done:
            return "Done"
        case .go:
            return "Go"
        case .join:
            return "Join"
        case .next:
            return "Next"
        case .return:
            return "Return"
        case .route:
            return "Route"
        case .search:
            return "Search"
        case .send:
            return "Send"
        }
    }

    @available(iOS 15.0, macOS 12.0, *)
    public var swiftUIValue: SwiftUI.SubmitLabel {
        switch self {
        case .continue:
            return .continue
        case .done:
            return .done
        case .go:
            return .go
        case .join:
            return .join
        case .next:
            return .next
        case .return:
            return .return
        case .route:
            return .route
        case .search:
            return .search
        case .send:
            return .send
        }
    }
}

// MARK: - Picker Style

public enum PickerStyle: Codable, CaseIterable, CustomStringConvertible, Identifiable {

    /// The default picker style, based on the picker’s context
    case automatic

    /// A PickerStyle where each option is displayed inline with other views in the current container.
    case inline

    /// A picker style that presents the options as a menu when the user presses a button, or as a submenu when nested within a larger menu.
    case menu

    /// A picker style represented by a navigation link that presents the options by pushing a List-style picker view.
    case navigationLink

    /// A picker style that presents the options in a segmented control.
    case segmented

    /// A picker style that presents the options in a scrollable wheel that shows the selected option and a few neighboring options.
    case wheel

    public var id: Self {
        self
    }

    public var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .inline:
            return "Inline"
        case .menu:
            return "Menu"
        case .navigationLink:
            return "Navigation Link"
        case .segmented:
            return "Segmented"
        case .wheel:
            return "Wheel"
        }
    }
}
