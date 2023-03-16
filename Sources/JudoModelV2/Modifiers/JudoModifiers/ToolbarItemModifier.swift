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

    public struct ToolbarItem: Codable, Equatable, Hashable, Identifiable {
        public var title: TextValue?
        public var icon: NamedIcon?
        public var placement: ToolbarItemPlacement = .automatic
        public var action: ButtonAction = .none
        public var id: UUID

        public init(
            title: TextValue? = nil,
            icon: NamedIcon? = nil,
            placement: ToolbarItemPlacement = .automatic,
            action: ButtonAction = ButtonAction.none,
            id: UUID = .init()
        ) {
            self.title = title
            self.icon = icon
            self.placement = placement
            self.action = action
            self.id = id
        }
    }

    @Published public var toolbarItem: ToolbarItem = .init()

    public required init() {
        super.init()
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! ToolbarItemModifier
        modifier.toolbarItem = toolbarItem
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case toolbarItem
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        toolbarItem = try container.decode(ToolbarItem.self, forKey: .toolbarItem)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toolbarItem, forKey: .toolbarItem)
        try super.encode(to: encoder)
    }
}

