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
public struct ImageNode: Node {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var position: CGPoint
    public var isLocked: Bool
    public var value: Variable<ImageReference>
    public var label: Variable<String>
    public var isDecorative: Bool
    public var resizing: ResizingMode
    public var renderingMode: TemplateRenderingMode
    public var symbolRenderingMode: SymbolRenderingMode
    
    public init(id: UUID, name: String?, children: [Node], position: CGPoint, isLocked: Bool, value: Variable<ImageReference>, label: Variable<String>, isDecorative: Bool, resizing: ResizingMode, renderingMode: TemplateRenderingMode, symbolRenderingMode: SymbolRenderingMode) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.isLocked = isLocked
        self.value = value
        self.label = label
        self.isDecorative = isDecorative
        self.resizing = resizing
        self.renderingMode = renderingMode
        self.symbolRenderingMode = symbolRenderingMode
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case position
        case isLocked
        case value
        case label
        case isDecorative
        case resizing
        case renderingMode
        case symbolRenderingMode
        
        // Beta 1 & 2
        case imageKind
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        position = try container.decode(CGPoint.self, forKey: .position)
        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        
        enum ImageKind: Codable {
            case system(name: String, renderingMode: SymbolRenderingMode)
            case content(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)
            case decorative(named: String, resizing: ResizingMode, renderingMode: TemplateRenderingMode)
        }
        
        // Beta 1 & 2
        if let kind = try? container.decode(ImageKind.self, forKey: .imageKind) {
            switch kind {
            case .system(let imageName, let symbolRenderingMode):
                self.value = Variable(.system(imageName: imageName))
                self.label = ""
                self.isDecorative = false
                self.resizing = .none
                self.renderingMode = .original
                self.symbolRenderingMode = symbolRenderingMode
            case .content(let imageName, let resizing, let renderingMode):
                self.value = Variable(.document(imageName: imageName))
                self.label = ""
                self.isDecorative = false
                self.resizing = resizing
                self.renderingMode = renderingMode
                self.symbolRenderingMode = .monochrome
            case .decorative(let imageName, let resizing, let renderingMode):
                self.value = Variable(.document(imageName: imageName))
                self.label = ""
                self.isDecorative = true
                self.resizing = resizing
                self.renderingMode = renderingMode
                self.symbolRenderingMode = .monochrome
            }
        } else {
            let meta = decoder.userInfo[.meta] as! Meta

            switch meta.version {
            case ..<17:
                value = try Variable(container.decode(LegacyImageValue.self, forKey: .value))
                label = try Variable(container.decode(LegacyTextValue.self, forKey: .label))
            default:
                value = try container.decode(Variable<ImageReference>.self, forKey: .value)
                label = try container.decode(Variable<String>.self, forKey: .label)
            }

            isDecorative = try container.decode(Bool.self, forKey: .isDecorative)
            resizing = try container.decode(ResizingMode.self, forKey: .resizing)
            renderingMode = try container.decode(TemplateRenderingMode.self, forKey: .renderingMode)
            symbolRenderingMode = try container.decode(SymbolRenderingMode.self, forKey: .symbolRenderingMode)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encode(position, forKey: .position)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(value, forKey: .value)
        try container.encode(label, forKey: .label)
        try container.encode(isDecorative, forKey: .isDecorative)
        try container.encode(resizing, forKey: .resizing)
        try container.encode(renderingMode, forKey: .renderingMode)
        try container.encode(symbolRenderingMode, forKey: .symbolRenderingMode)
    }
}
