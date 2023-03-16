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
import SwiftUI

@objc public class Layer: Element, Dependable {
    
    public var modifiers: [JudoModifier] {
        get {
            children.allOf(type: JudoModifier.self)
        }
        
        set {
          let newChildren: [Node] = children.filter { !($0 is JudoModifier) }
          
          newValue.forEach { $0.parent = self }
          children = newChildren + newValue
        }
    }
    
    @Published @objc public dynamic var isLocked = false

    public required init() {
        super.init()
    }
    
    // MARK: Hierarchy
    
    override public var isLeaf: Bool {
        !children.contains { node in
            switch node {
            case is Layer:
                return true
            case is BackgroundModifier:
                return true
            case is OverlayModifier:
                return true
            case is MaskModifier:
                return true
            default:
                return false
            }
        }
    }
    
    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        switch type {
        case is JudoModifier.Type:
            return true
        default:
            return false
        }
    }
    
    // MARK: Traits
        
    public var traits: Traits {
        .none
    }
    
    // MARK: Applicable Actions
    
    public var applicableActions: ApplicableActions {
        var actions: ApplicableActions = [
            .copy,
            .cut,
            .delete,
            .embedInStack,
            .lock,
            .move,
            .paste,
            .pasteOver,
            .useAsModifier
        ]

        if let parent = parent, parent.canAcceptChild(ofType: Spacer.self) {
            actions.insert(.addSpacer)
        }

        return actions
    }
    
    // MARK: Assets
        
    public func colorReferences() -> [Binding<ColorReference>] {
        var references = [Binding<ColorReference>]()
        
        func colorBinding<S: JudoModifier>(
            _ source: S,
            keyPath: ReferenceWritableKeyPath<S, ColorReference>
        ) -> Binding<ColorReference> {
            Binding {
                source[keyPath: keyPath]
                
            } set: { newValue in
                source[keyPath: keyPath] = newValue
                
            }
        }
        
        let modifierColorReferenceBindings = modifiers
            .compactMap { modifier in
                switch modifier {
                case let source as ForegroundColorModifier:
                    return colorBinding(source, keyPath: \.color)
                case let source as ShadowModifier:
                    return colorBinding(source, keyPath: \.color)
                case let source as TintModifier:
                    return colorBinding(source, keyPath: \.color)
                case let source as ToolbarBackgroundColorModifier:
                    return colorBinding(source, keyPath: \.color)
                default:
                    return nil
                }
            }
            
        references.append(contentsOf: modifierColorReferenceBindings)
        return references
    }
    
    public func gradientReferences() -> [Binding<GradientReference>] {
        return []
    }

    public func fontAssets() -> [Font] {
        modifiers.compactMap({ ($0 as? FontModifier)?.font })
    }
    
    public func removeFonts(_ fonts: [FontFamily], undoManager: UndoManager?) {
        let fontModifiers = modifiers.compactMap({$0 as? FontModifier })
        fontModifiers.forEach { fontModifier in
            switch fontModifier.font {
            case .document(let fontFamily, let textStyle) where fonts.contains(fontFamily):
                fontModifier.set(\.font, to: .dynamic(textStyle: textStyle, design: .default), undoManager: undoManager)
            case .custom(let fontName, let size):
                if fonts.contains(fontName.family) {
                    fontModifier.set(\.font, to: .fixed(size: size, weight: fontName.weight, design: .default), undoManager: undoManager)
                }
            default:
                break
            }
        }
    }
    
    /// Returns any text strings (keys) used by this layer.
    public func strings() -> [String] {
        return []
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let layer = super.copy(with: zone) as! Layer

        // Modifiers
        layer.modifiers = modifiers.map {
            $0.copy() as! JudoModifier
        }
        
        layer.isLocked = isLocked
        return layer
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case isLocked
        case modifiers
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isLocked = try container.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isLocked, forKey: .isLocked)
        try super.encode(to: encoder)
    }
}

// MARK: Sequence

extension Sequence where Element: Node {
    
    public func gatherColorReferences() -> [Binding<ColorReference>] {
        
        flatten()
            .compactMap {
                $0 as? Layer
            }
            .flatMap {
                $0.colorReferences()
            }
    }
    
    public func gatherGradientReferences() -> [Binding<GradientReference>] {
        flatten()
            .compactMap {
                $0 as? Layer
            }
            .flatMap {
                $0.gradientReferences()
            }
    }
    
    public func gatherStrings() -> [String] {
        flatten()
            .compactMap {
                $0 as? Layer
            }
            .flatMap {
                $0.strings()
            }
    }

    public func gatherFonts() -> [Font] {
        flatten()
            .compactMap {
                $0 as? Layer
            }
            .flatMap {
                $0.fontAssets()
            }
    }
}
