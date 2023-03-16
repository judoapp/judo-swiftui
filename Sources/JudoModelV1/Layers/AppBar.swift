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

/// Android-specific App Bar.
public final class AppBar: Node {
    public var title: String { willSet { objectWillChange.send() } }
    public var hideUpIcon: Bool = false { willSet { objectWillChange.send() } }

    public var buttonColor: ColorReference =  ColorReference(systemName: "white") { willSet { objectWillChange.send() } }
    public var titleFont: Font = Font.fixed(size: 20, weight: .medium) { willSet { objectWillChange.send() } }
    public var titleColor: ColorReference = ColorReference(systemName: "white") { willSet { objectWillChange.send() } }
    /// Note that this is actually replaced with a Document Color at insertion time, in order to allow us to offer a light/dark variant of the default background color.
    public var backgroundColor: ColorReference = ColorReference(customColor: AppBar.defaultBackgroundLight) { willSet { objectWillChange.send() } }
        
    required public init() {
        title = AppBar.humanName
        super.init()
    }
    
    public init(title: String) {
        self.title = title
        super.init()
    }
    
    override public class var humanName: String {
        "App Bar"
    }
    
    override public var traits: Traits {
        .iosIncompatible
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild(ofType type: Node.Type) -> Bool {
        switch type {
        case is AppBarMenuItem.Type:
            return true
        default:
            return false
        }
    }
    
    // MARK: Children
    
    public var menuItems: [AppBarMenuItem] {
        children
            .compactMap { $0 as? AppBarMenuItem }
    }
    
    // MARK: Assets
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        [
            Binding(get: { self.buttonColor }, set: { self.buttonColor = $0 }),
            Binding(get: { self.titleColor }, set: { self.titleColor = $0 }),
            Binding(get: { self.backgroundColor }, set: { self.backgroundColor = $0 })
        ] + super.colorReferences()
    }

    override public func fontAssets() -> [Font] {
        super.fontAssets() + [titleFont]
    }

    override public func removeFonts(_ fonts: [FontFamily], undoManager: UndoManager?) {
        switch titleFont {
        case .document(let fontFamily, let textStyle) where fonts.contains(fontFamily):
            set(\.titleFont, to: .dynamic(textStyle: textStyle, emphases: []), undoManager: undoManager)
        case .custom(let fontName, let size):
            if fonts.contains(fontName.family) {
                set(\.titleFont, to: .fixed(size: size, weight: fontName.weight), undoManager: undoManager)
            }
        default:
            break
        }
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let appBar = super.copy(with: zone) as! AppBar
        appBar.title = title
        appBar.hideUpIcon = hideUpIcon
        appBar.buttonColor = buttonColor
        appBar.titleFont = titleFont
        appBar.titleColor = titleColor
        appBar.backgroundColor = backgroundColor
        return appBar
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case title
        case menuItems
        case hideUpIcon
        case buttonColor
        case titleFont
        case titleColor
        case backgroundColor
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.hideUpIcon = try container.decode(Bool.self, forKey: .hideUpIcon)
        self.buttonColor = try container.decode(ColorReference.self, forKey: .buttonColor)
        self.titleFont = try container.decode(Font.self, forKey: .titleFont)
        self.titleColor = try container.decode(ColorReference.self, forKey: .titleColor)
        self.backgroundColor = try container.decode(ColorReference.self, forKey: .backgroundColor)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(hideUpIcon, forKey: .hideUpIcon)
        try container.encode(buttonColor, forKey: .buttonColor)
        try container.encode(titleFont, forKey: .titleFont)
        try container.encode(titleColor, forKey: .titleColor)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try super.encode(to: encoder)
    }
    
    // MARK: Default Colors
    
    public static let defaultBackgroundLight = ColorValue(rgbHex: "6200EEFF")
    public static let defaultBackgroundDark = ColorValue(rgbHex: "BB86FCFF")
}
