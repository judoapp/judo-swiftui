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

public enum Font: Codable, Hashable {
    case dynamic(textStyle: FontTextStyle, design: FontDesign)
    case fixed(size: Variable<Double>, weight: FontWeight, design: FontDesign)
    case document(fontFamily: FontFamily, textStyle: FontTextStyle)
    case custom(fontName: FontName, size: Variable<Double>)

    // MARK: Codable
    
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
        let meta = decoder.userInfo[.meta] as! Meta

        let caseName = try container.decode(String.self, forKey: .caseName)
        switch caseName {
        case "dynamic":
            let textStyle = try container.decode(FontTextStyle.self, forKey: .textStyle)
            let design = try container.decode(FontDesign.self, forKey: .design)
            self = .dynamic(textStyle: textStyle, design: design)
        case "fixed":
            let weight = try container.decode(FontWeight.self, forKey: .weight)
            let design = try container.decode(FontDesign.self, forKey: .design)

            switch meta.version {
            case ..<16:
                let size = try container.decode(CGFloat.self, forKey: .size)
                self = .fixed(size: Variable(LegacyNumberValue(size)), weight: weight, design: design)
            case ..<17:
                let size = try container.decode(LegacyNumberValue.self, forKey: .size)
                self = .fixed(size: Variable(size), weight: weight, design: design)
            default:
                let size = try container.decode(Variable<Double>.self, forKey: .size)
                self = .fixed(size: size, weight: weight, design: design)
            }
        case "document":
            let fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)
            let textStyle = try container.decode(FontTextStyle.self, forKey: .textStyle)
            self = .document(fontFamily: fontFamily, textStyle: textStyle)
        case "custom":
            let fontName = try container.decode(FontName.self, forKey: .fontName)
            switch meta.version {
            case ..<16:
                let size = try container.decode(CGFloat.self, forKey: .size)
                self = .custom(fontName: fontName, size: Variable(LegacyNumberValue(size)))
            case ..<17:
                let size = try container.decode(LegacyNumberValue.self, forKey: .size)
                self = .custom(fontName: fontName, size: Variable(size))
            default:
                let size = try container.decode(Variable<Double>.self, forKey: .size)
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
