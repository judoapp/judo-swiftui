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
import OrderedCollections

@objc public class Node: NSObject, Codable, Identifiable, NSCopying, ObservableObject, UndoableObject {
    public class var humanName: String {
        typeName
    }
    
    public class var typeName: String {
        String(describing: Self.self)
    }
    
    public private(set) var id: ID
    
    @Published @objc public dynamic var name: String?
    @Published @objc public dynamic var parent: Node?
    @Published @objc public dynamic var children = [Node]()
    
    override public required init() {
        self.id = .create()
        super.init()
    }
    
    public convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    // MARK: Description
    
    @objc dynamic override public var description: String {
        name ?? type(of: self).humanName
    }

    override public var debugDescription: String {
        return "\(description) (\(id))"
    }
    
    /// An array of stringly typed key paths that affect the value of a node's description. Subclasses should override this value if their description is computed based on properties in addition to the node's name.
    public class var keyPathsAffectingDescription: Set<String> {
        []
    }
    
    // MARK: Hierarchy
    
    /// Determines whether the node can be moved within the document hierarchy.
    public var isMovable: Bool {
        true
    }
    
    /// Determines whether the node can be emoved entirely from the document hierarchy.
    public var isRemovable: Bool {
        true
    }
    
    @objc dynamic public var isLeaf: Bool {
        true
    }
    
    public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        false
    }
    
    // MARK: KVO

    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)

        switch key {
        case "description":
            keyPaths.insert("name")
            keyPaths.formUnion(keyPathsAffectingDescription)
        case "isLeaf":
            keyPaths.insert("children")
        default:
            break
        }
        
        return keyPaths
    }
    
    // MARK: NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        let node = Self()
        node.id = .create()
        node.name = name
        node.parent = nil
        
        node.children = children.compactMap {
            let child = $0.copy() as! Node
            child.parent = node
            return child
        }
        
        return node
    }
    
    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Node.ID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        super.init()
        
        for child in children {
            child.parent = self
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(children, forKey: .children)
    }
}

// MARK: Node.ID

extension Node {
    public typealias ID = String
}

fileprivate extension Node.ID {
    static func create() -> Self {
        UUID().uuidString
    }
}

// MARK: Traversal

extension Node {
    public var enclosingComponent: MainComponent? {
        if let mainComponent = self as? MainComponent {
            return mainComponent
        }
        
        func firstComponentAncestor(of node: Node) -> MainComponent? {
            guard let parent = node.parent else {
                return nil
            }

            if let mainComponent = parent as? MainComponent {
                return mainComponent
            }

            return firstComponentAncestor(of: parent)
        }

        return firstComponentAncestor(of: self)
    }
    
    public func firstAncestor(where predicate: (Node) -> Bool) -> Node? {
        predicate(self) ? self : parent?.firstAncestor(where: predicate)
    }
}

// MARK: Sequence

extension Sequence where Element: Node {
    public func flatten() -> [Node] {
        flatMap { node -> [Node] in
            [node] + node.children.flatten()
        }
    }
    
    /// Calls the given closure on each element in the sequence, then recursively calls the traverse function on each element's children.
    ///
    /// - Parameters:
    ///     - block: The closure called on each element in the sequence hierarchy. Returning `false` breaks out of the enumeration.
    public func traverse(_ block: (Node) -> Bool) {
        for node in self {
            if !block(node) {
                break
            }
            node.children.traverse(block)
        }
    }

    /// From an array of nodes, remove any descendents already contained within the tree. The result is an array containing the minimum set of nodes that can be traversed to access every node in the original array.
    ///
    /// Consider an array containing nodes A, B, C, D and E that exist in the following tree structure:
    /// ```
    /// • A
    ///     • B
    /// • C
    ///     • D
    ///         • E
    /// ```
    ///
    /// The `rootNodes` property would return nodes A and C only as B, D, and E exist as descendents of the root nodes A and C.
    ///
    public var rootNodes: [Node] {
        var result = OrderedSet<Node>()
        
        func alreadyContainsAncestor(ofNode node: Node) -> Bool {
            guard let parent = node.parent else {
                return false
            }
            
            if result.contains(parent) {
                return true
            } else {
                return alreadyContainsAncestor(ofNode: parent)
            }
        }
        
        func removeChildren(ofParent parent: Node) {
            parent.children.forEach { child in
                removeChildren(ofParent: child)
                result.remove(child)
            }
        }
        
        forEach { node in
            if alreadyContainsAncestor(ofNode: node) {
                return
            }
            
            removeChildren(ofParent: node)
            result.append(node)
        }
        
        return result.elements
    }

    /// Traverses the layer graph, starting with the layer's children, until it finds a layer that matches the
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

    /// Traverses the layer graph, starting with the layer's children, until it finds a layer that matches the
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
}
