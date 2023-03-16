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

import CoreGraphics
import SwiftUI

public final class Text: Layer {
    public enum Transform: String, Codable {
        case uppercase
        case lowercase
    }
    
    @objc public dynamic var text = "Lorem ipsum dolor sit amet" { willSet { objectWillChange.send() } }
    public var font = Font.body { willSet { objectWillChange.send() } }
    public var textColor = ColorReference(systemName: "label") { willSet { objectWillChange.send() } }
    public var textAlignment = TextAlignment.leading { willSet { objectWillChange.send() } }
    public var lineLimit: Int? { willSet { objectWillChange.send() } }
    public var transform: Transform?  { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    public init(text: String) {
        self.text = text
        super.init()
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(20))
    }
    
    override public class var keyPathsAffectingDescription: Set<String> {
        ["text"]
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
            .actionable,
            .accessible,
            .metadatable,
            .codePreview
        ]
    }
    
    // MARK: Assets
    
    override public func strings() -> [String] {
        var strings = super.strings()
        strings.append(text)
        return strings
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let text = super.copy(with: zone) as! Text
        text.text = self.text
        text.font = font
        text.textColor = textColor.copy() as! ColorReference
        text.textAlignment = textAlignment
        text.lineLimit = lineLimit
        text.transform = transform
        return text
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case text
        case font
        case textColor
        case textAlignment
        case lineLimit
        case transform
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        font = try container.decode(Font.self, forKey: .font)
        textColor = try container.decode(ColorReference.self, forKey: .textColor)
        textAlignment = try container.decode(TextAlignment.self, forKey: .textAlignment)
        lineLimit = try container.decodeIfPresent(Int.self, forKey: .lineLimit)
        transform = try container.decodeIfPresent(Transform.self, forKey: .transform)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(font, forKey: .font)
        try container.encode(textColor, forKey: .textColor)
        try container.encode(textAlignment, forKey: .textAlignment)
        try container.encodeIfPresent(lineLimit, forKey: .lineLimit)
        try container.encodeIfPresent(transform, forKey: .transform)
        try super.encode(to: encoder)
    }
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        [
            Binding(get: { self.textColor }, set: { self.textColor = $0 })
        ] + super.colorReferences()
    }

    override public func fontAssets() -> [Font] {
        super.fontAssets() + [font]
    }

    override public func removeFonts(_ fonts: [FontFamily], undoManager: UndoManager?) {
        switch font {
        case .document(let fontFamily, let textStyle) where fonts.contains(fontFamily):
            set(\.font, to: .dynamic(textStyle: textStyle, emphases: []), undoManager: undoManager)
        case .custom(let fontName, let size):
            if fonts.contains(fontName.family) {
                set(\.font, to: .fixed(size: size, weight: fontName.weight), undoManager: undoManager)
            }
        default:
            break
        }
    }
}
