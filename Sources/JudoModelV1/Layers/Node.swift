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

@objc public class Node: NSObject, Codable, Dependable, Identifiable, NSCopying, ObservableObject {
    public class var humanName: String {
        typeName
    }
    
    public typealias ID = String
    public private(set) var id: ID
    
    @Published @objc public dynamic var name: String?
    @Published public var parent: Node?
    @Published @objc public dynamic var children = [Node]()
    @Published public var segue: Segue?
    
    // Layout
    @Published public var ignoresSafeArea: Set<Edge>?
    @Published public var aspectRatio: CGFloat?
    @Published public var padding: Padding?
    @Published public var frame: Frame?
    @Published public var layoutPriority: Double?
    @Published public var offset: CGPoint?
    
    // Appearance
    @Published public var shadow: Shadow?
    @Published public var opacity: Double?
    
    // Layering
    @Published public var background: Background?
    @Published public var overlay: Overlay?
    @Published public var mask: Node?
    
    // Interaction
    @Published public var action: Action?
    @Published public var accessibility: Accessibility?
    
    // Metadata
    @Published public var metadata: Metadata?
    
    override public required init() {
        self.id = .create()
        super.init()
    }
    
    // MARK: Description
    
    override public var description: String {
        name ?? type(of: self).humanName
    }

    override public var debugDescription: String {
        return "\(type(of: self)) \(description) (\(id))"
    }

    public class var keyPathsAffectingDescription: Set<String> {
        []
    }
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        
        if key == "description" {
            keyPaths.insert("name")
            keyPaths.formUnion(keyPathsAffectingDescription)
        }
        
        return keyPaths
    }
    
    // MARK: Hierarchy
    
    @objc public var isLeaf: Bool {
        true
    }
    
    public func canAcceptChild(ofType type: Node.Type) -> Bool {
        false
    }
    
    public var enclosingScreen: Screen? {
        func firstScreenAncestor(of node: Node) -> Screen? {
            guard let parent = node.parent else {
                return nil
            }
                
            if let screen = parent as? Screen {
                return screen
            }

            return firstScreenAncestor(of: parent)
        }

        return firstScreenAncestor(of: self)
    }
    
    // MARK: Traits
        
    public var traits: Traits {
        .none
    }
    
    // MARK: Applicable Actions
    
    public var applicableActions: ApplicableActions {
        .none
    }
    
    // MARK: Assets
        
    public func colorReferences() -> [Binding<ColorReference>] {
        var references = [Binding<ColorReference>]()
        
        if let background = background {
            references.append(contentsOf: background.node.colorReferences())
        }
        
        if let shadow = shadow {
            references.append(
                Binding {
                    shadow.color
                } set: { [weak self] in
                    self?.shadow?.color = $0
                }
            )
        }
        
        if let overlay = overlay {
            references.append(contentsOf: overlay.node.colorReferences())
        }
        
        if let mask = mask {
            references.append(contentsOf: mask.colorReferences())
        }
        
        return references
    }
    
    public func gradientReferences() -> [Binding<GradientReference>] {
        var references = [Binding<GradientReference>]()
        
        if let background = background {
            references.append(contentsOf: background.node.gradientReferences())
        }
        
        if let overlay = overlay {
            references.append(contentsOf: overlay.node.gradientReferences())
        }
        
        if let mask = mask {
            references.append(contentsOf: mask.gradientReferences())
        }
        
        return references
    }
    
    public func imageAssets() -> [ImageValue] {
        var assets = [ImageValue]()
        
        if let background = background {
            assets.append(contentsOf: background.node.imageAssets())
        }
        
        if let overlay = overlay {
            assets.append(contentsOf: overlay.node.imageAssets())
        }
        
        if let mask = mask {
            assets.append(contentsOf: mask.imageAssets())
        }
        
        return assets
    }
    
    public func mediaAssets() -> [MediaValue] {
        []
    }

    public func fontAssets() -> [Font] {
        []
    }
    
    public func removeFonts(_ fonts: [FontFamily], undoManager: UndoManager?) {
    }
    
    /// Returns any text strings (keys) used by this node.
    public func strings() -> [String] {
        var strings = [String]()
        if let accessibilityLabel = accessibility?.label {
            strings.append(accessibilityLabel)
        }
        return strings
    }
    
    // MARK: NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let node = Self()
        node.id = ID.create()
        node.name = name
        node.parent = nil

        node.children = children.compactMap {
            let child = $0.copy() as! Node
            child.parent = node
            return child
        }
        
        // Layout
        node.ignoresSafeArea = ignoresSafeArea
        node.aspectRatio = aspectRatio
        node.padding = padding
        node.frame = frame
        node.layoutPriority = layoutPriority
        node.offset = offset
        
        // Appearance
        node.shadow = shadow
        node.opacity = opacity
        
        // Layering
        node.background = background
        node.overlay = overlay
        node.mask = mask?.copy() as? Node
        
        // Interaction
        switch action {
        case .performSegue:
            // We can't be sure the segue's destination is a valid screen for
            // the node's new destination.
            node.action = nil
        default:
            node.action = action
        }
        
        node.accessibility = accessibility
        node.metadata = metadata
        return node
    }
    
    // MARK: Codable

    public class var typeName: String {
        String(describing: Self.self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case childIDs
        case isSelected
        case isCollapsed
        case ignoresSafeArea
        case aspectRatio
        case padding
        case frame
        case layoutPriority
        case offset
        case shadow
        case opacity
        case background
        case overlay
        case mask
        case action
        case accessibility
        case metadata
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Node.ID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        // Layout
        ignoresSafeArea = try container.decodeIfPresent(Set<Edge>.self, forKey: .ignoresSafeArea)
        aspectRatio = try container.decodeIfPresent(CGFloat.self, forKey: .aspectRatio)
        padding = try container.decodeIfPresent(Padding.self, forKey: .padding)
        frame = try container.decodeIfPresent(Frame.self, forKey: .frame)
        layoutPriority = try container.decodeIfPresent(Double.self, forKey: .layoutPriority)
        offset = try container.decodeIfPresent(CGPoint.self, forKey: .offset)
        
        // Appearance
        shadow = try container.decodeIfPresent(Shadow.self, forKey: .shadow)
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity)
        
        // Layering
        background = try container.decodeIfPresent(Background.self, forKey: .background)
        overlay = try container.decodeIfPresent(Overlay.self, forKey: .overlay)
        mask = try container.decodeNodeIfPresent(forKey: .mask)
        
        // Interaction
        action = try container.decodeIfPresent(Action.self, forKey: .action)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
        
        // Metadata
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        
        super.init()
        
        coordinator.registerOneToManyRelationship(
            nodeIDs: try container.decode([Node.ID].self, forKey: .childIDs),
            to: self,
            keyPath: \.children,
            inverseKeyPath: \.parent
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(children.map { $0.id }, forKey: .childIDs)
        
        // Layout
        try container.encodeIfPresent(ignoresSafeArea, forKey: .ignoresSafeArea)
        try container.encodeIfPresent(aspectRatio, forKey: .aspectRatio)
        try container.encodeIfPresent(padding, forKey: .padding)
        try container.encodeIfPresent(frame, forKey: .frame)
        try container.encodeIfPresent(layoutPriority, forKey: .layoutPriority)
        try container.encodeIfPresent(offset, forKey: .offset)
        
        // Appearance
        try container.encodeIfPresent(shadow, forKey: .shadow)
        try container.encodeIfPresent(opacity, forKey: .opacity)
        
        // Layering
        try container.encodeIfPresent(background, forKey: .background)
        try container.encodeIfPresent(overlay, forKey: .overlay)
        try container.encodeIfPresent(mask, forKey: .mask)
        
        // Interaction
        try container.encodeIfPresent(action, forKey: .action)
        try container.encodeIfPresent(accessibility, forKey: .accessibility)
        
        // Metadata
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}

// MARK: Sequence

extension Sequence where Element: Node {
    
    /// Traverses the node graph, starting with the node's children, until it finds a node that matches the
    /// supplied predicate, from the top of the z-order.
    public func highest(where predicate: (Node) -> Bool) -> Node? {
        reduce(nil) { result, node in
            guard result == nil else {
                return result
            }
            
            if predicate(node) {
                return node
            }
            
            return node.children.highest(where: predicate)
        }
    }
    
    /// Traverses the node graph, starting with the node's children, until it finds a node that matches the
    /// supplied predicate, from the bottom of the z-order.
    public func lowest(where predicate: (Node) -> Bool) -> Node? {
        reversed().reduce(nil) { result, node in
            guard result == nil else {
                return result
            }
            
            if predicate(node) {
                return node
            }
            
            return node.children.lowest(where: predicate)
        }
    }
    
    public func traverse(_ block: (Node) -> Void) {
        forEach { node in
            block(node)
            node.children.traverse(block)
        }
    }

    public func flatten() -> [Node] {
        flatMap { node -> [Node] in
            [node] + node.children.flatten()
        }
    }
    
    public func gatherColorReferences() -> [Binding<ColorReference>] {
        flatten().flatMap {
            $0.colorReferences()
        }
    }
    
    public func gatherGradientReferences() -> [Binding<GradientReference>] {
        flatten().flatMap {
            $0.gradientReferences()
        }
    }
        
    public func gatherImages() -> [ImageValue] {
        flatten().flatMap {
            $0.imageAssets()
        }
    }
    
    public func gatherMedia() -> [MediaValue] {
        flatten().flatMap {
            $0.mediaAssets()
        }
    }
    
    public func gatherStrings() -> [String] {
        return self.flatten().flatMap {
            $0.strings()
        }
    }

    public func gatherFonts() -> [Font] {
        flatten().flatMap {
            $0.fontAssets()
        }
    }
}

// MARK: Node.ID

fileprivate extension Node.ID {
    static func create() -> Node.ID {
        UUID().uuidString
    }
}
