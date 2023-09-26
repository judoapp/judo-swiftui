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

public class ToolbarItemModifier: JudoModifier {
    @Published public var title: Variable<String>?
    @Published public var icon: NamedIcon?
    @Published public var placement: ToolbarItemPlacement = .automatic
    @Published @objc public dynamic var actions: [Action] = []
    
    public required init() {
        super.init()
    }
    
    // MARK: NSCopying
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! ToolbarItemModifier
        modifier.title = title
        modifier.icon = icon
        modifier.placement = placement
        modifier.actions = actions
        return modifier
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case title
        case icon
        case placement
        case actions
        
        // ..<15
        case toolbarItem
    }
    
    public required init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch coordinator.documentVersion {
        case ..<15:
            let legacyToolbarItem = try container.decode(LegacyToolbarItem.self, forKey: .toolbarItem)
            if let title = legacyToolbarItem.title {
                self.title = Variable(title)
            }
            icon = legacyToolbarItem.icon
            placement = legacyToolbarItem.placement
            actions = legacyToolbarItem.actions
        case ..<17:
            title = try Variable(container.decode(LegacyTextValue.self, forKey: .title))
            icon = try container.decode(NamedIcon?.self, forKey: .icon)
            placement = try container.decode(ToolbarItemPlacement.self, forKey: .placement)
            actions = try container.decode([ActionWrapper].self, forKey: .actions).compactMap(\.action)
        default:
            title = try container.decode(Variable<String>?.self, forKey: .title)
            icon = try container.decode(NamedIcon?.self, forKey: .icon)
            placement = try container.decode(ToolbarItemPlacement.self, forKey: .placement)
            actions = try container.decode([ActionWrapper].self, forKey: .actions).compactMap(\.action)
        }

        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(placement, forKey: .placement)
        try container.encode(actions, forKey: .actions)
        try super.encode(to: encoder)
    }
}

