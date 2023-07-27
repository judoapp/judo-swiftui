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

public final class Button: Layer, Modifiable {
    @Published public dynamic var role: ButtonRole = .none
    @Published @objc public dynamic var actions: [Action] = []

    required public init() {
        super.init()
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        false
    }
    
    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is Layer.Type, is JudoModifier.Type:
            return true
        default:
            return false
        }
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let button = super.copy(with: zone) as! Button
        button.role = role
        button.actions = actions
        return button
    }

    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case role
        case actions
        
        // Legacy
        case buttonAction
    }

    public required init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(ButtonRole.self, forKey: .role)
        
        switch coordinator.documentVersion {
        case ..<14:
            let legacyAction = try container.decode(LegacyAction.self, forKey: .buttonAction)
            actions = [legacyAction.action]
        case 14:
            let legacyActions = try container.decode([LegacyAction].self, forKey: .actions)
            actions = legacyActions.map(\.action)
        default:
            actions = try container.decode([ActionWrapper].self, forKey: .actions).compactMap(\.action)
        }
        
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(actions, forKey: .actions)
        try super.encode(to: encoder)
    }
}
