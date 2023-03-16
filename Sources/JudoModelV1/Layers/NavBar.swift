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

/// iOS-specific Nav Bar.
public final class NavBar: Node {
    override public class var humanName: String {
        "Nav Bar"
    }
    
    public enum TitleDisplayMode: String, Codable {
        case inline
        case large
    }
    
    public struct Appearance: Codable, Hashable {
        public static var inlineDefault = Appearance(
            titleColor: ColorReference(systemName: "label"),
            buttonColor: ColorReference(systemName: "systemBlue"),
            background: .translucent
        )
        
        public static var largeDefault = Appearance(
            titleColor: ColorReference(systemName: "label"),
            buttonColor: ColorReference(systemName: "systemBlue"),
            background: .transparent
        )
        
        public var titleColor: ColorReference
        public var buttonColor: ColorReference
        public var background: Background
        
        public init(
            titleColor: ColorReference,
            buttonColor: ColorReference,
            background: Background
        ) {
            self.titleColor = titleColor
            self.buttonColor = buttonColor
            self.background = background
        }
    }
    
    public struct Background: Codable, Hashable {
        public static var translucent: Background {
            Background(
                fillColor: ColorReference(systemName: "clear"),
                shadowColor: ColorReference(
                    customColor: ColorValue(red: 0, green: 0, blue: 0, alpha: 0.3)
                ),
                blurEffect: true
            )
        }
        
        public static var opaque: Background {
            Background(
                fillColor: ColorReference(systemName: "systemBackground"),
                shadowColor: ColorReference(
                    customColor: ColorValue(red: 0, green: 0, blue: 0, alpha: 0.3)
                ),
                blurEffect: false
            )
        }
        
        public static var transparent: Background {
            Background(
                fillColor: ColorReference(systemName: "clear"),
                shadowColor: ColorReference(systemName: "clear"),
                blurEffect: false
            )
        }
        
        public var fillColor: ColorReference
        public var shadowColor: ColorReference
        public var blurEffect: Bool
        
        public init(
            fillColor: ColorReference,
            shadowColor: ColorReference,
            blurEffect: Bool
        ) {
            self.fillColor = fillColor
            self.shadowColor = shadowColor
            self.blurEffect = blurEffect
        }
    }
    
    public var title: String { willSet { objectWillChange.send() } }
    public var titleDisplayMode = TitleDisplayMode.inline { willSet { objectWillChange.send() } }
    public var hidesBackButton = false  { willSet { objectWillChange.send() } }
    public var titleFont = Font.body  { willSet { objectWillChange.send() } }
    public var largeTitleFont = Font.largeTitle  { willSet { objectWillChange.send() } }
    public var buttonFont = Font.body  { willSet { objectWillChange.send() } }
    public var appearance = Appearance.inlineDefault { willSet { objectWillChange.send() } }
    public var alternateAppearance: Appearance? { willSet { objectWillChange.send() } }
    
    required public init() {
        title = NavBar.humanName
        super.init()
    }
    
    public init(title: String) {
        self.title = title
        super.init()
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild(ofType type: Node.Type) -> Bool {
        switch type {
        case is NavBarButton.Type:
            return true
        default:
            return false
        }
    }
    
    // MARK: Children
    
    public var leadingButtons: [NavBarButton] {
        children
            .compactMap { $0 as? NavBarButton }
            .filter { $0.placement == .leading }
    }
    
    public var trailingButtons: [NavBarButton] {
        children
            .compactMap { $0 as? NavBarButton }
            .filter { $0.placement == .trailing }
    }
    
    // MARK: Assets
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        var references = super.colorReferences()
        
        references.append(contentsOf: [
            Binding {
                self.appearance.titleColor
            } set: {
                self.appearance.titleColor = $0
            },
            Binding {
                self.appearance.buttonColor
            } set: {
                self.appearance.buttonColor = $0
            },
            Binding {
                self.appearance.background.fillColor
            } set: {
                self.appearance.background.fillColor = $0
            },
            Binding {
                self.appearance.background.shadowColor
            } set: {
                self.appearance.background.shadowColor = $0
            }
        ])
        
        if let alternateAppearance = self.alternateAppearance {
            references.append(contentsOf: [
                Binding {
                    alternateAppearance.titleColor
                } set: {
                    self.alternateAppearance?.titleColor = $0
                },
                Binding {
                    alternateAppearance.buttonColor
                } set: {
                    self.alternateAppearance?.buttonColor = $0
                },
                Binding {
                    alternateAppearance.background.fillColor
                } set: {
                    self.alternateAppearance?.background.fillColor = $0
                },
                Binding {
                    alternateAppearance.background.shadowColor
                } set: {
                    self.alternateAppearance?.background.shadowColor = $0
                }
            ])
        }
        
        return references
    }

    override public func fontAssets() -> [Font] {
        super.fontAssets() + [titleFont, largeTitleFont, buttonFont]
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
        switch largeTitleFont {
        case .document(let fontFamily, let textStyle) where fonts.contains(fontFamily):
            set(\.largeTitleFont, to: .dynamic(textStyle: textStyle, emphases: []), undoManager: undoManager)
        case .custom(let fontName, let size):
            if fonts.contains(fontName.family) {
                set(\.largeTitleFont, to: .fixed(size: size, weight: fontName.weight), undoManager: undoManager)
            }
        default:
            break
        }
        switch buttonFont {
        case .document(let fontFamily, let textStyle) where fonts.contains(fontFamily):
            set(\.buttonFont, to: .dynamic(textStyle: textStyle, emphases: []), undoManager: undoManager)
        case .custom(let fontName, let size):
            if fonts.contains(fontName.family) {
                set(\.buttonFont, to: .fixed(size: size, weight: fontName.weight), undoManager: undoManager)
            }
        default:
            break
        }
    }

    
    override public func strings() -> [String] {
        var strings = super.strings()
        
        strings.append(self.title)
        
        return strings
    }
    
    override public var traits: Traits {
        [
            .metadatable,
            .androidIncompatible
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let navBar = super.copy(with: zone) as! NavBar
        navBar.title = title
        navBar.titleDisplayMode = titleDisplayMode
        navBar.hidesBackButton = hidesBackButton
        navBar.titleFont = titleFont
        navBar.largeTitleFont = largeTitleFont
        navBar.buttonFont = buttonFont
        navBar.appearance = appearance
        navBar.alternateAppearance = appearance
        return navBar
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case title
        case titleDisplayMode
        case hidesBackButton
        case titleFont
        case largeTitleFont
        case buttonFont
        case appearance
        case alternateAppearance
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        titleDisplayMode = try container.decode(TitleDisplayMode.self, forKey: .titleDisplayMode)
        hidesBackButton = try container.decode(Bool.self, forKey: .hidesBackButton)
        titleFont = try container.decode(Font.self, forKey: .titleFont)
        largeTitleFont = try container.decode(Font.self, forKey: .largeTitleFont)
        buttonFont = try container.decode(Font.self, forKey: .buttonFont)
        appearance = try container.decode(Appearance.self, forKey: .appearance)
        alternateAppearance = try container.decodeIfPresent(Appearance.self, forKey: .alternateAppearance)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(titleDisplayMode, forKey: .titleDisplayMode)
        try container.encode(hidesBackButton, forKey: .hidesBackButton)
        try container.encode(titleFont, forKey: .titleFont)
        try container.encode(largeTitleFont, forKey: .largeTitleFont)
        try container.encode(buttonFont, forKey: .buttonFont)
        try container.encode(appearance, forKey: .appearance)
        try container.encodeIfPresent(alternateAppearance, forKey: .alternateAppearance)
        try super.encode(to: encoder)
    }
}
