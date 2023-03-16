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

public final class AppBarMenuItem: Node {
    public enum ShowAsAction: String, Codable, Hashable, CaseIterable {
        case always
        case never
        case ifRoom
    }
    
    // MARK: Properties
    
    public var title: String = "Menu Item" { willSet { self.objectWillChange.send() } }
    public var showAsAction: ShowAsAction = .ifRoom { willSet { self.objectWillChange.send() } }
    public var iconMaterialName: String = "help" { willSet { self.objectWillChange.send() } }

    required public init() {
        super.init()
    }
    
    override public class var humanName: String {
        "App Bar Menu Item"
    }
    
    override public var traits: Traits {
        [.iosIncompatible, .actionable, .accessible]
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let appBarMenuItem = super.copy(with: zone) as! AppBarMenuItem
        appBarMenuItem.title = title
        appBarMenuItem.showAsAction = showAsAction
        appBarMenuItem.iconMaterialName = iconMaterialName
        return appBarMenuItem
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case title
        case iconMaterialName
        case showAsAction
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        iconMaterialName = try container.decode(String.self, forKey: .iconMaterialName)
        showAsAction = try container.decode(ShowAsAction.self, forKey: .showAsAction)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(iconMaterialName, forKey: .iconMaterialName)
        try container.encode(showAsAction, forKey: .showAsAction)
        try super.encode(to: encoder)
    }
}
