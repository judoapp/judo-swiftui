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

    public enum Kind: Codable, Hashable {

        /// System Image (SF Symbols)
        case system(name: String, renderingMode: SymbolRenderingMode)

        /// Content Image (Assets)
        case content(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)

        /// Decorative image
        case decorative(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)

        public static let defaultSystem = Kind.system(name: "globe", renderingMode: .monochrome)
        public static let defaultContent = Kind.content(named: "", resizing: .none, renderingMode: .original)
        public static let defaultDecorative = Kind.decorative(named: "", resizing: .none, renderingMode: .original)
        
    }

    @Published public var kind: Kind
    @Published public var label: TextValue = ""

    public var assetNames: [String] {
        switch kind {
        case .content(let name, _, _), .decorative(let name, _, _):
            return [name]
        case .system:
            return []
        }
    }

    /// Returns the image object associated with the specified name.
    /// - Parameters:
    ///   - name: The name associated with the desired image. This is the name of an image asset in assets catalog.
    ///   - resizing: The resizing mode for the image.
    ///   - renderingMode: A setting that determines how the app renders an image.
    public init(named name: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode) {
        kind = .content(named: name, resizing: resizing, renderingMode: renderingMode)
        super.init()
    }

    required public init() {
        kind = .defaultSystem
        super.init()
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        return super.description
    }
    
    override public class var keyPathsAffectingDescription: Set<String> {
        ["originalFileName"]
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
        let image = super.copy(with: zone) as! Image
        image.kind = kind
        return image
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case originalFileName
        case imageKind
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(Image.Kind.self, forKey: .imageKind)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .imageKind)
        try super.encode(to: encoder)
    }

}
