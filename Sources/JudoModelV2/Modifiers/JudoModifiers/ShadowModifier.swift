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

public class ShadowModifier: JudoModifier {

    @Published public var color: ColorReference = ColorReference(
        customColor: ColorValue(red: 0, green: 0, blue: 0, alpha: 0.3333)
    )
    @Published public var offset: CGSize = .init()
    @Published public var radius: CGFloat = 4

    public required init() {
        super.init()
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! ShadowModifier
        modifier.color = color.copy() as! ColorReference
        modifier.offset = offset
        modifier.radius = radius
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case color
        case offset
        case radius
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(ColorReference.self, forKey: .color)
        offset = try container.decode(CGSize.self, forKey: .offset)
        radius = try container.decode(CGFloat.self, forKey: .radius)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(offset, forKey: .offset)
        try container.encode(radius, forKey: .radius)
        try super.encode(to: encoder)
    }
}
