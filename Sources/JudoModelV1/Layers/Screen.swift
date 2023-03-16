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

public class Screen: Node {
    @objc public dynamic var isInitialScreen = false {
        willSet { objectWillChange.send() }
    }
    
    public var inboundSegues = [Segue]() {
        willSet { objectWillChange.send() }
    }
    
    public var statusBarStyle = StatusBarStyle.default {
        willSet { objectWillChange.send() }
    }
    
    public var androidStatusBarStyle = StatusBarStyle.light {
        willSet { objectWillChange.send() }
    }
    
    public var androidStatusBarBackgroundColor = ColorReference(
        customColor: ColorValue(rgbHex: "3700B3FF")
    ) {
        willSet { objectWillChange.send() }
    }
    
    public var backButtonStyle: BackButtonStyle {
        willSet { objectWillChange.send() }
    }
    
    public var backgroundColor = ColorReference(systemName: "systemBackground") {
        willSet { objectWillChange.send() }
    }
    
    public required init() {
        backButtonStyle = .default(title: Screen.humanName)
        super.init()
    }
    
    public init(name: String) {
        backButtonStyle = .default(title: name)
        super.init()
        self.name = name
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild(ofType type: Node.Type) -> Bool {
        switch type {
        case is NavBar.Type:
            return navBar == nil
        case is AppBar.Type:
            return appBar == nil
        case is Rectangle.Type:
            return true
        case is Text.Type:
            return true
        case is Image.Type:
            return true
        case is Icon.Type:
            return true
        case is Video.Type:
            return true
        case is Audio.Type:
            return true
        case is HStack.Type:
            return true
        case is VStack.Type:
            return true
        case is ZStack.Type:
            return true
        case is ScrollContainer.Type:
            return true
        case is Carousel.Type:
            return true
        case is PageControl.Type:
            return true
        case is DataSource.Type:
            return true
        case is CollectionNode.Type:
            return true
        case is Conditional.Type:
            return true
        case is WebViewNode.Type:
            return true
        default:
            return false
        }
    }

    // MARK: Traits

    override public var traits: Traits {
        [.metadatable]
    }
    
    // MARK: Children
    
    public var navBar: NavBar? {
        children.first { $0 is NavBar } as? NavBar
    }
    
    public var appBar: AppBar? {
        children.first { $0 is AppBar } as? AppBar
    }
    
    public var layers: [Layer] {
        children.compactMap { $0 as? Layer }
    }
    
    // MARK: Segues
    
    public var upstreamScreens: Set<Screen> {
        inboundSegues.reduce(into: []) { result, segue in
            if let enclosingScreen = segue.source.enclosingScreen {
                result.insert(enclosingScreen)
                result.formUnion(enclosingScreen.upstreamScreens)
            }
        }
    }
    
    // MARK: Applicable Actions
    
    override public var applicableActions: ApplicableActions {
        var actions: ApplicableActions = [
            .cut,
            .copy,
            .paste,
            .pasteOver,
            .delete,
            .move
        ]

        if !isInitialScreen {
            actions.insert(.setInitialScreen)
        }

        return actions
    }
    
    // MARK: Assets
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        let backgroundColorBinding = Binding<ColorReference> {
            self.backgroundColor
        } set: { newValue in
            self.backgroundColor = newValue
        }

        let androidStatusBarColorBackgroundBinding = Binding<ColorReference> {
            self.androidStatusBarBackgroundColor
        } set: { newValue in
            self.androidStatusBarBackgroundColor = newValue
        }
        
        return super.colorReferences() + [backgroundColorBinding, androidStatusBarColorBackgroundBinding]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let screen = super.copy(with: zone) as! Screen
        screen.isInitialScreen = false
        screen.statusBarStyle = statusBarStyle
        screen.androidStatusBarStyle = androidStatusBarStyle
        screen.androidStatusBarBackgroundColor = androidStatusBarBackgroundColor
        screen.backButtonStyle = backButtonStyle
        screen.backgroundColor = backgroundColor
        return screen
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case isInitialScreen
        case statusBarStyle
        case androidStatusBarStyle
        case androidStatusBarBackgroundColor
        case backButtonStyle
        case backgroundColor
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        isInitialScreen = try container.decode(Bool.self, forKey: .isInitialScreen)
        statusBarStyle = try container.decode(StatusBarStyle.self, forKey: .statusBarStyle)
        
        if coordinator.documentVersion >= 7 {
            androidStatusBarStyle = try container.decode(StatusBarStyle.self, forKey: .androidStatusBarStyle)
        } else {
            androidStatusBarStyle = .light
        }
        
        backButtonStyle = try container.decode(BackButtonStyle.self, forKey: .backButtonStyle)
        backgroundColor = try container.decode(ColorReference.self, forKey: .backgroundColor)
                
        if coordinator.documentVersion >= 7 {
            androidStatusBarBackgroundColor = try container.decode(ColorReference.self, forKey: .androidStatusBarBackgroundColor)
        } else {
            androidStatusBarBackgroundColor = ColorReference(customColor: ColorValue(rgbHex: "3700B3FF"))
        }
        
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isInitialScreen, forKey: .isInitialScreen)
        try container.encode(statusBarStyle, forKey: .statusBarStyle)
        try container.encode(androidStatusBarStyle, forKey: .androidStatusBarStyle)
        try container.encode(backButtonStyle, forKey: .backButtonStyle)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(androidStatusBarBackgroundColor, forKey: .androidStatusBarBackgroundColor)
        try super.encode(to: encoder)
    }
}
