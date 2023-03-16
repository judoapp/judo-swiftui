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
import UIKit

extension Color {
    static func standardColor(named name: String) -> Color? {
        switch name {
        case "black":
            return .black
        case "blue":
            return .blue
        case "clear":
            return .clear
        case "gray":
            return .gray
        case "green":
            return .green
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "primary":
            return .primary
        case "purple":
            return .purple
        case "red":
            return .red
        case "secondary":
            return .secondary
        case "white":
            return .white
        case "yellow":
            return .yellow
        default:
            return nil
        }
    }

    static func named(_ name: String) -> Color {
        if let standardColor = standardColor(named: name) {
            return standardColor
        }

        return Color(UIColor.named(name))
    }

    static let allNames = [
        "label",
        "secondaryLabel",
        "tertiaryLabel",
        "quaternaryLabel",
        "systemFill",
        "secondarySystemFill",
        "tertiarySystemFill",
        "quaternarySystemFill",
        "placeholderText",
        "systemBackground",
        "secondarySystemBackground",
        "tertiarySystemBackground",
        "systemGroupedBackground",
        "secondarySystemGroupedBackground",
        "tertiarySystemGroupedBackground",
        "separator",
        "opaqueSeparator",
        "link",
        "darkText",
        "lightText",
        "systemBlue",
        "systemGreen",
        "systemIndigo",
        "systemOrange",
        "systemPink",
        "systemPurple",
        "systemRed",
        "systemTeal",
        "systemYellow",
        "systemGray",
        "systemGray2",
        "systemGray3",
        "systemGray4",
        "systemGray5",
        "systemGray6"
    ]

    /// In English (that is, the "C" Locale), will be localized as needed in the UI layer.
    static let humanNames: [String: String] = [
        "label": "Primary Label",
        "secondaryLabel" : "Secondary Label",
        "tertiaryLabel" : "Tertiary Label",
        "quaternaryLabel" : "Quaternary Label",
        "systemFill" : "Primary Fill",
        "secondarySystemFill" : "Secondary System Fill",
        "tertiarySystemFill" : "Tertiary System Fill",
        "quaternarySystemFill" : "Quaternary System Fill",
        "placeholderText" : "Placeholder Text",
        "systemBackground": "Primary Background",
        "secondarySystemBackground" : "Secondary Background",
        "tertiarySystemBackground" : "Tertiary System Background",
        "systemGroupedBackground" : "System Grouped Background",
        "secondarySystemGroupedBackground" : "Secondary Grouped Background",
        "tertiarySystemGroupedBackground" : "Tertiary Grouped Background",
        "separator" : "Separator",
        "opaqueSeparator" : "Opaque Separator",
        "link": "Link",
        "darkText" : "Dark Text",
        "lightText": "Light Text",
        "black": "Black",
        "white": "White",
        "clear": "Clear",
        "systemBlue": "Blue",
        "systemGreen": "Green",
        "systemIndigo": "Indigo",
        "systemOrange": "Orange",
        "systemPink": "Pink",
        "systemPurple": "Purple",
        "systemRed": "Red",
        "systemTeal": "Teal",
        "systemYellow": "Yellow",
        "systemGray": "System Gray",
        "systemGray2": "System Gray 2",
        "systemGray3": "System Gray 3",
        "systemGray4": "System Gray 4",
        "systemGray5": "System Gray 5",
        "systemGray6": "System Gray 6"
    ]

    enum NameCategory: String, CaseIterable {
        case systemColors = "System Colors"
        case systemGrays = "System Grays"
        case fillColors = "Fill Colors"
        case textColors = "Text Colors"
    }

    static let nameCategories: [NameCategory: [String]] = [
        .systemColors : [
            "black",
            "white",
            "clear",
            "systemBlue",
            "systemGreen",
            "systemIndigo",
            "systemOrange",
            "systemPink",
            "systemPurple",
            "systemRed",
            "systemTeal",
            "systemYellow"
        ],
        .systemGrays: [
            "systemGray",
            "systemGray2",
            "systemGray3",
            "systemGray4",
            "systemGray5",
            "systemGray6"
        ],
        .fillColors: [
            "systemFill",
            "secondarySystemFill",
            "tertiarySystemFill",
            "quaternarySystemFill",
            "placeholderText",
            "systemBackground",
            "secondarySystemBackground",
            "tertiarySystemBackground",
            "systemGroupedBackground",
            "secondarySystemGroupedBackground",
            "tertiarySystemGroupedBackground",
            "separator",
            "opaqueSeparator"
        ],
        .textColors: [
            "label",
            "secondaryLabel",
            "tertiaryLabel",
            "quaternaryLabel",
            "link",
            "darkText",
            "lightText"
        ]
    ]
}

extension UIColor {
    static func named(_ name: String) -> UIColor {
        guard let color = semanticColor(named: name) ?? standardColor(named: name) else {
            assertionFailure("Invalid color name: \"\(name)\"")
            return .clear
        }

        return color
    }

    private static func semanticColor(named name: String) -> UIColor? {
        switch name {
        case "label":
            return .label
        case "secondaryLabel":
            return .secondaryLabel
        case "tertiaryLabel":
            return .tertiaryLabel
        case "quaternaryLabel":
            return .quaternaryLabel
        case "systemFill":
            return .systemFill
        case "secondarySystemFill":
            return .secondarySystemFill
        case "tertiarySystemFill":
            return .tertiarySystemFill
        case "quaternarySystemFill":
            return .quaternarySystemFill
        case "placeholderText":
            return .placeholderText
        case "systemBackground":
            return .systemBackground
        case "secondarySystemBackground":
            return .secondarySystemBackground
        case "tertiarySystemBackground":
            return .tertiarySystemBackground
        case "systemGroupedBackground":
            return .systemGroupedBackground
        case "secondarySystemGroupedBackground":
            return .secondarySystemGroupedBackground
        case "tertiarySystemGroupedBackground":
            return .tertiarySystemGroupedBackground
        case "separator":
            return .separator
        case "opaqueSeparator":
            return .opaqueSeparator
        case "link":
            return .link
        case "darkText":
            return .darkText
        case "lightText":
            return .lightText
        case "systemBlue":
            return .systemBlue
        case "systemGreen":
            return .systemGreen
        case "systemIndigo":
            return .systemIndigo
        case "systemOrange":
            return .systemOrange
        case "systemPink":
            return .systemPink
        case "systemPurple":
            return .systemPurple
        case "systemRed":
            return .systemRed
        case "systemTeal":
            return .systemTeal
        case "systemYellow":
            return .systemYellow
        case "systemGray":
            return .systemGray
        case "systemGray2":
            return .systemGray2
        case "systemGray3":
            return .systemGray3
        case "systemGray4":
            return .systemGray4
        case "systemGray5":
            return .systemGray5
        case "systemGray6":
            return .systemGray6
        case "black":
            return .black
        default:
            return nil
        }
    }

    private static func standardColor(named name: String) -> UIColor? {
        switch name {
        case "black":
            return .black
        case "blue":
            return .systemBlue
        case "clear":
            return .clear
        case "gray":
            return .systemGray
        case "green":
            return .systemGreen
        case "orange":
            return .systemOrange
        case "purple":
            return .systemPurple
        case "red":
            return .systemRed
        case "white":
            return .white
        case "yellow":
            return .systemYellow
        default:
            return nil
        }
    }
}
