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

public class Shape: Layer, Modifiable {
    @Published public var rasterizationStyle: RasterizationStyle = .fill
    @Published public var shapeStyle: ShapeStyle = .default
    @Published public var lineWidth: CGFloat = 1
    
    required public init() {
        super.init()
    }
    
    // MARK: Assets
        
    override public func colorReferences() -> [Binding<ColorReference>] {
        var references = [Binding<ColorReference>]()
        
        if case .flat(let color) = shapeStyle {
            references.append(
                Binding(
                    get: { color },
                    set: { [weak self] newReference in
                        self?.shapeStyle = .flat(newReference)
                    }
                )
            )
        }
        
        return references + super.colorReferences()
    }
    
    override public func gradientReferences() -> [Binding<GradientReference>] {
        var references = [Binding<GradientReference>]()
        
        if case .gradient(let gradient) = shapeStyle {
            references.append(
                Binding(
                    get: { gradient },
                    set: { [weak self] newReference in
                        self?.shapeStyle = .gradient(gradient)
                    }
                )
            )
        }
        
        return references
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let shape = super.copy(with: zone) as! Shape
        shape.rasterizationStyle = rasterizationStyle
        shape.shapeStyle = shapeStyle
        shape.lineWidth = lineWidth
        return shape
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case rasterizationStyle
        case shapeStyle
        case lineWidth
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rasterizationStyle = try container.decode(RasterizationStyle.self, forKey: .rasterizationStyle)
        shapeStyle = try container.decode(ShapeStyle.self, forKey: .shapeStyle)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rasterizationStyle, forKey: .rasterizationStyle)
        try container.encode(shapeStyle, forKey: .shapeStyle)
        try container.encode(lineWidth, forKey: .lineWidth)
        try super.encode(to: encoder)
    }
}
