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
