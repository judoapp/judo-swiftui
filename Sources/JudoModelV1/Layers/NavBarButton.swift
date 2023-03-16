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

public final class NavBarButton: Node {
    override public class var humanName: String {
        "Nav Bar Button"
    }
    
    public enum Placement: String, Codable {
        case leading
        case trailing
    }
    
    public enum Style: String, Codable {
        case custom
        case done
        case close
    }
    
    public var placement: Placement {
        willSet {
            objectWillChange.send()
        }
        
        didSet {
            // When the placement value changes, the nav bar needs to re-render
            // to adjust the positioning of its buttons.
            parent?.objectWillChange.send()
        }
    }
    
    public var style: Style {
        willSet {
            objectWillChange.send()
        }
        
        didSet {
            // When the style value changes, the nav bar needs to re-render
            // to adjust the positioning of its buttons.
            parent?.objectWillChange.send()
        }
    }
    
    public var title: String? { willSet { objectWillChange.send() } }
    
    public var icon: NamedIcon? {
        willSet {
            objectWillChange.send()
        }
        
        didSet {
            // When the icon value changes, the nav bar needs to re-render
            // to adjust the positioning of its buttons.
            parent?.objectWillChange.send()
        }
    }
    
    required public init() {
        placement = .trailing
        style = .done
        super.init()
    }
    
    public init(_ placement: Placement) {
        self.placement = placement
        style = .done
        super.init()
    }
    
    override public var traits: Traits {
        [
            .metadatable,
            .androidIncompatible
        ]
    }
    
    // MARK: Assets
    
    override public func strings() -> [String] {
        var strings = super.strings()
        if let title = title {
            strings.append(title)
        }
        return strings
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let navBarButton = super.copy(with: zone) as! NavBarButton
        navBarButton.placement = placement
        navBarButton.style = style
        navBarButton.title = title
        navBarButton.icon = icon
        return navBarButton
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case placement
        case style
        case title
        case icon
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placement = try container.decode(Placement.self, forKey: .placement)
        style = try container.decode(Style.self, forKey: .style)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        icon = try container.decodeIfPresent(NamedIcon.self, forKey: .icon)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(placement, forKey: .placement)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(icon, forKey: .icon)
        try super.encode(to: encoder)
    }
}
