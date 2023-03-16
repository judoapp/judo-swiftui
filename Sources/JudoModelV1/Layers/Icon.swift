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

public final class Icon: Layer {
    public var icon = NamedIcon(symbolName: "chevron.right", materialName: "chevron_right") { willSet { objectWillChange.send() } }

    /// Size of the icon in points.
    public var pointSize = 17  { willSet { objectWillChange.send() } }
    public var color = ColorReference(systemName: "secondaryLabel") { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .layerable,
            .actionable,
            .accessible,
            .metadatable,
            .codePreview
        ]
    }
    
    // MARK: Assets
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        let colorBinding = Binding<ColorReference> {
            self.color
        } set: { newValue in
            self.color = newValue
        }
        
        return super.colorReferences() + [colorBinding]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let icon = super.copy(with: zone) as! Icon
        icon.icon = self.icon
        icon.pointSize = self.pointSize
        icon.color = color.copy() as! ColorReference
        return icon
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case pointSize
        case icon
        case color
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        icon = try container.decode(NamedIcon.self, forKey: .icon)
        pointSize = try container.decode(Int.self, forKey: .pointSize)
        color = try container.decode(ColorReference.self, forKey: .color)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(icon, forKey: .icon)
        try container.encode(pointSize, forKey: .pointSize)
        try container.encode(color, forKey: .color)
        try super.encode(to: encoder)
    }
}
