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

public final class Rectangle: Layer {
    public var fill = Fill.default { willSet { objectWillChange.send() } }
    public var border: Border? { willSet { objectWillChange.send() } }
    public var cornerRadius = 0 { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .resizable,
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
        var references = [Binding<ColorReference>]()
        
        if case .flat(let color) = fill {
            references.append(
                Binding(
                    get: { color },
                    set: { [weak self] newReference in
                        self?.fill = .flat(newReference)
                    }
                )
            )
        }
        
        if let border = border {
            references.append(
                Binding(
                    get: { border.color },
                    set: { [weak self] newReference in
                        self?.border?.color = newReference
                    }
                )
            )
        }
        
        return references + super.colorReferences()
    }
    
    override public func gradientReferences() -> [Binding<GradientReference>] {
        var references = [Binding<GradientReference>]()
        
        if case .gradient(let gradient) = fill {
            references.append(
                Binding(
                    get: { gradient },
                    set: { [weak self] newReference in
                        self?.fill = .gradient(gradient)
                    }
                )
            )
        }
        
        return references
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let rectangle = super.copy(with: zone) as! Rectangle
        rectangle.fill = fill
        rectangle.border = border
        rectangle.cornerRadius = cornerRadius
        return rectangle
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case fill
        case border
        case cornerRadius
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fill = try container.decode(Fill.self, forKey: .fill)
        border = try container.decodeIfPresent(Border.self, forKey: .border)
        cornerRadius = try container.decode(Int.self, forKey: .cornerRadius)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fill, forKey: .fill)
        try container.encodeIfPresent(border, forKey: .border)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try super.encode(to: encoder)
    }
}
