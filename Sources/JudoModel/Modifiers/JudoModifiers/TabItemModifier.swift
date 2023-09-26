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

public class TabItemModifier: JudoModifier {

    public struct TabItem: Codable, Equatable, Hashable {
        public var title: Variable<String>?
        public var icon: NamedIcon?

        public init(title: Variable<String>? = nil, icon: NamedIcon? = nil) {
            self.title = title
            self.icon = icon
        }

        // MARK: Codable

        private enum CodingKeys: String, CodingKey {
            case title
            case icon
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

            switch coordinator.documentVersion {
            case ..<17:
                title = try Variable(container.decode(LegacyTextValue.self, forKey: .title))
                icon = try container.decodeIfPresent(NamedIcon.self, forKey: .icon)
            default:
                title = try container.decode(Variable<String>.self, forKey: .title)
                icon = try container.decodeIfPresent(NamedIcon.self, forKey: .icon)
            }

        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encodeIfPresent(icon, forKey: .icon)
        }
    }

    @Published public var tabItem: TabItem = .init()

    public required init() {
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.tabItem.title, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! TabItemModifier
        modifier.tabItem = tabItem
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case tabItem
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tabItem = try container.decode(TabItem.self, forKey: .tabItem)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabItem, forKey: .tabItem)
        try super.encode(to: encoder)
    }
}
