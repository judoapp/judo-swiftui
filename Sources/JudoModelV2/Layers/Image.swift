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
import os.log

/// A layer that displays an image.
public final class Image: Layer, Modifiable, AssetProvider {
    @Published public var value: ImageValue
    @Published public var label: TextValue = ""
    @Published public var isDecorative: Bool = false
    @Published public var resizing: ResizingMode = .none
    @Published public var renderingMode: TemplateRenderingMode = .original
    @Published public var symbolRenderingMode: SymbolRenderingMode = .monochrome

    public var assetNames: [String] {
        switch value {
        case .reference(let imageReference):
            switch imageReference {
            case .document(let imageName):
                return [imageName]
            default:
                return []
            }
        default:
            return []
        }
    }

    public init(_ name: String?) {
        if let name {
            value = .reference(imageReference: .document(imageName: name))
        } else {
            value = .default
        }
        
        super.init()
    }

    required public init() {
        value = .default
        super.init()
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        return super.description
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
            .lockable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let image = super.copy(with: zone) as! Self
        image.value = value
        image.label = label
        image.isDecorative = isDecorative
        image.resizing = resizing
        image.renderingMode = renderingMode
        image.symbolRenderingMode = symbolRenderingMode
        return image
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case value
        case label
        case isDecorative
        case resizing
        case renderingMode
        case symbolRenderingMode
        
        // Beta 1 & 2
        case imageKind
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        enum ImageKind: Codable {
            case system(name: String, renderingMode: SymbolRenderingMode)
            case content(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)
            case decorative(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)
        }
        
        // Beta 1 & 2
        if let kind = try? container.decode(ImageKind.self, forKey: .imageKind) {
            switch kind {
            case .system(let imageName, let symbolRenderingMode):
                self.value = .reference(imageReference: .system(imageName: imageName))
                self.symbolRenderingMode = symbolRenderingMode
            case .content(let imageName, let resizing, let renderingMode):
                self.value = .reference(imageReference: .document(imageName: imageName))
                self.resizing = resizing
                self.renderingMode = renderingMode
            case .decorative(let imageName, let resizing, let renderingMode):
                self.value = .reference(imageReference: .document(imageName: imageName))
                self.isDecorative = true
                self.resizing = resizing
                self.renderingMode = renderingMode
            }
        } else {
            value = try container.decode(ImageValue.self, forKey: .value)
            label = try container.decode(TextValue.self, forKey: .label)
            isDecorative = try container.decode(Bool.self, forKey: .isDecorative)
            resizing = try container.decode(ResizingMode.self, forKey: .resizing)
            renderingMode = try container.decode(TemplateRenderingMode.self, forKey: .renderingMode)
            symbolRenderingMode = try container.decode(SymbolRenderingMode.self, forKey: .symbolRenderingMode)
        }
        
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(label, forKey: .label)
        try container.encode(isDecorative, forKey: .isDecorative)
        try container.encode(resizing, forKey: .resizing)
        try container.encode(renderingMode, forKey: .renderingMode)
        try container.encode(symbolRenderingMode, forKey: .symbolRenderingMode)
        try super.encode(to: encoder)
    }
}
