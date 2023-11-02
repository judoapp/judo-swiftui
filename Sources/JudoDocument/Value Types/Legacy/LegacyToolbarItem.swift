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

struct LegacyToolbarItem: Decodable {
    var title: LegacyTextValue?
    var icon: NamedIcon?
    var placement: ToolbarItemPlacement = .automatic
    var actions: [Action] = []
    var id: UUID
    
    private enum CodingKeys: CodingKey {
        case title
        case icon
        case placement
        case actions
        case id
        
        // ..<14
        case action
    }
    
    init(from decoder: Decoder) throws {
        let meta = decoder.userInfo[.meta] as! Meta
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decodeIfPresent(LegacyTextValue.self, forKey: .title)
        icon = try container.decodeIfPresent(NamedIcon.self, forKey: .icon)
        placement = try container.decode(ToolbarItemPlacement.self, forKey: .placement)
        
        switch meta.version {
        case ..<14:
            let legacyAction = try container.decode(LegacyAction.self, forKey: .action)
            actions = [legacyAction.action]
        case 14:
            let legacyActions = try container.decode([LegacyAction].self, forKey: .actions)
            actions = legacyActions.map(\.action)
        default:
            throw DecodingError.typeMismatch(
                LegacyAction.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "LegacyToolbarItem shouldn't be used for document versions greater than 14",
                    underlyingError: nil
                )
            )
        }
        
        id = try container.decode(UUID.self, forKey: .id)
    }
}
