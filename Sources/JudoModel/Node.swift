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

public class Node: JudoObject {
    @Published @objc public dynamic var name: String?
    @Published @objc public dynamic var parent: Node?
    @Published @objc public dynamic var children = [Node]()
    
    public required init() {
        super.init()
    }
    
    public convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    // MARK: Description
    
    @objc dynamic override public var description: String {
        name ?? super.description
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
        case "isLeaf":
            keyPaths.insert("children")
        default:
            break
        }
        
        return keyPaths
    }
    
    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let node = super.copy(with: zone) as! Self
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
        case name
        case children
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        children = try container.decodeNodes(forKey: .children)
        try super.init(from: decoder)
        
        for child in children {
            child.parent = self
        }
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(children, forKey: .children)
        try super.encode(to: encoder)
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

    /// Recursively traverse through the node hierarchy collecting any `MainComponent`s referenced by `ComponentInstance` layers.
    public func referencedComponents() -> Set<MainComponent> {
        func extractComponents(from nodes: [Node], enclosingMainComponent: MainComponent? = nil, into partialResult: inout Set<MainComponent>) {
            for node in nodes {
                switch node {
                case let componentInstance as ComponentInstance:
                    extractComponents(
                        from: componentInstance.value,
                        enclosingMainComponent: enclosingMainComponent,
                        into: &partialResult
                    )
                    
                    for `override` in componentInstance.overrides.values {
                        switch `override` {
                        case .component(let value):
                            extractComponents(
                                from: value,
                                enclosingMainComponent: enclosingMainComponent,
                                into: &partialResult
                            )
                        default:
                            break
                        }
                    }
                default:
                    extractComponents(
                        from: node.children,
                        enclosingMainComponent: enclosingMainComponent,
                        into: &partialResult
                    )
                }
            }
        }
        
        func extractComponents(from value: ComponentInstance.ComponentValue, enclosingMainComponent: MainComponent?, into partialResult: inout Set<MainComponent>) {
            let mainComponent = value.resolve(
                properties: enclosingMainComponent?.properties ?? [:]
            )
            
            if let mainComponent, !partialResult.contains(mainComponent) {
                extractComponents(from: mainComponent, into: &partialResult)
            }
        }
        
        func extractComponents(from mainComponent: MainComponent, into partialResult: inout Set<MainComponent>) {
            partialResult.insert(mainComponent)
            
            for property in mainComponent.properties.values {
                switch property {
                case .component(let mainComponent):
                    extractComponents(from: mainComponent, into: &partialResult)
                default:
                    break
                }
            }
            
            let layers = mainComponent.children.compactMap { element -> Layer? in
                guard let layer = element as? Layer else {
                    assertionFailure("All children must be layers")
                    return nil
                }
                
                return layer
            }
            
            extractComponents(
                from: layers,
                enclosingMainComponent: mainComponent,
                into: &partialResult
            )
        }
        
        var referencedComponents = Set<MainComponent>()
        extractComponents(from: Array(self), into: &referencedComponents)
        return referencedComponents
    }
}
