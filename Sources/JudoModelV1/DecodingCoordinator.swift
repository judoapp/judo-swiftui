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
import os.log

final public class DecodingCoordinator {
    private var pendingRelationships = [PendingRelationship]()
    public var documentVersion: Int
    var compatibilityVersion: Int
    var images: Set<ImageValue>
    var media: Set<MediaValue>
    var fonts: Set<FontValue>
    public var localizations: DocumentLocalizations

    public init(documentVersion: Int, compatibilityVersion: Int, images: Set<ImageValue>, media: Set<MediaValue>, fonts: Set<FontValue>, localizations: DocumentLocalizations) {
        self.documentVersion = documentVersion
        self.compatibilityVersion = compatibilityVersion
        self.images = images
        self.media = media
        self.fonts = fonts
        self.localizations = localizations
    }
    
    public func imageByFilename(_ filename: String) -> ImageValue? {
        images.first(where: { $0.filename == filename })
    }
    
    public func assetByFilename<T: AssetValue>(_ filename: String) -> T? {
        (media.first(where: { $0.filename == filename }) as? T) ?? (images.first(where: { $0.filename == filename }) as? T)
    }
    
    public func registerOneToOneRelationship<T, U>(
        nodeID: Node.ID,
        to object: T,
        keyPath: ReferenceWritableKeyPath<T, U?>,
        inverseKeyPath: ReferenceWritableKeyPath<U, T?>? = nil
    ) where T: AnyObject, U: Node {
        pendingRelationships.append(
            OneToOneRelationship(
                object: object,
                keyPath: keyPath,
                nodeID: nodeID,
                inverseKeyPath: inverseKeyPath
            )
        )
    }
    
    public func registerOneToManyRelationship<T, U>(
        nodeIDs: [Node.ID],
        to object: T,
        keyPath: ReferenceWritableKeyPath<T, [U]>,
        inverseKeyPath: ReferenceWritableKeyPath<U, T?>? = nil
    ) where T: AnyObject, U: Node {
        pendingRelationships.append(
            OneToManyRelationship(
                object: object,
                keyPath: keyPath,
                nodeIDs: nodeIDs,
                inverseKeyPath: inverseKeyPath
            )
        )
    }
    
    public func registerManyToOneRelationship<T, U>(
        nodeID: Node.ID,
        to object: T,
        keyPath: ReferenceWritableKeyPath<T, U?>,
        inverseKeyPath: ReferenceWritableKeyPath<U, [T]>? = nil
    ) where T: AnyObject, U: Node {
        pendingRelationships.append(
            ManyToOneRelationship(
                object: object,
                keyPath: keyPath,
                nodeID: nodeID,
                inverseKeyPath: inverseKeyPath
            )
        )
    }
    
    public func registerColorRelationship<T: AnyObject>(colorID: DocumentColor.ID, to: T, keyPath: ReferenceWritableKeyPath<T, DocumentColor?>) {
        pendingRelationships.append(DocumentColorRelationship(object: to, keyPath: keyPath, colorID: colorID))
    }
    
    public func registerGradientRelationship<T: AnyObject>(gradientID: DocumentGradient.ID, to: T, keyPath: ReferenceWritableKeyPath<T, DocumentGradient?>) {
        pendingRelationships.append(DocumentGradientRelationship(object: to, keyPath: keyPath, gradientID: gradientID))
    }
    
    // TODO: Consider replacing relationships with deferred blocks
    
    private var deferredBlocks = [() throws -> Void]()
    
    func `defer`(block: @escaping () throws -> Void) {
        deferredBlocks.append(block)
    }

    var nodes = [Node.ID: Node]()
    
    public func resolveRelationships(nodes: [Node], documentColors: [DocumentColor], documentGradients: [DocumentGradient]) throws {
        self.nodes = nodes.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        
        let colorsByID = documentColors.reduce(into: [DocumentColor.ID: DocumentColor]()) { (hash, color) in
            hash[color.id] = color
        }
        
        let gradientsByID = documentGradients.reduce(into: [DocumentGradient.ID: DocumentGradient]()) { (hash, gradient) in
            hash[gradient.id] = gradient
        }
        
        pendingRelationships.forEach { $0.resolve(nodes: self.nodes, documentColors: colorsByID, documentGradients: gradientsByID) }
        pendingRelationships = []
        
        try deferredBlocks.forEach { block in
            try block()
        }
    }
}

fileprivate protocol PendingRelationship {
    func resolve(
        nodes: [Node.ID: Node],
        documentColors: [DocumentColor.ID: DocumentColor],
        documentGradients: [DocumentGradient.ID: DocumentGradient]
    )
}

fileprivate struct OneToOneRelationship<T, U>: PendingRelationship where T: AnyObject, U: Node {
    var object: T
    var keyPath: ReferenceWritableKeyPath<T, U?>
    var nodeID: Node.ID
    var inverseKeyPath: ReferenceWritableKeyPath<U, T?>?
    
    func resolve(nodes: [Node.ID : Node], documentColors: [DocumentColor.ID : DocumentColor], documentGradients: [DocumentGradient.ID : DocumentGradient]) {
        guard let node = nodes[nodeID] as? U else {
            assertionFailure("""
                Failed to resolve relationship. No node found with id \
                \(nodeID).
                """
            )
            
            return
        }
        
        object[keyPath: keyPath] = node
        
        if let inverseKeyPath = inverseKeyPath {
            node[keyPath: inverseKeyPath] = object
        }
    }
}

fileprivate struct OneToManyRelationship<T, U>: PendingRelationship where T: AnyObject, U: Node {
    var object: T
    var keyPath: ReferenceWritableKeyPath<T, [U]>
    var nodeIDs: [Node.ID]
    var inverseKeyPath: ReferenceWritableKeyPath<U, T?>?
    
    func resolve(nodes: [Node.ID : Node], documentColors: [DocumentColor.ID : DocumentColor], documentGradients: [DocumentGradient.ID : DocumentGradient]) {
        object[keyPath: keyPath] = nodeIDs.compactMap { nodeID in
            guard let node = nodes[nodeID] as? U else {
                os_log("Failed to resolve relationship. No node found with id: %@", type: .error, nodeID)
                return nil
            }
            
            if let inverseKeyPath = inverseKeyPath {
                node[keyPath: inverseKeyPath] = object
            }
            
            return node
        }
    }
}

fileprivate struct ManyToOneRelationship<T, U>: PendingRelationship where T: AnyObject, U: Node {
    var object: T
    var keyPath: ReferenceWritableKeyPath<T, U?>
    var nodeID: Node.ID
    var inverseKeyPath: ReferenceWritableKeyPath<U, [T]>?
    
    func resolve(nodes: [Node.ID : Node], documentColors: [DocumentColor.ID : DocumentColor], documentGradients: [DocumentGradient.ID : DocumentGradient]) {
        guard let node = nodes[nodeID] as? U else {
            assertionFailure("""
                Failed to resolve relationship. No node found with id \
                \(nodeID).
                """
            )
            
            return
        }
        
        object[keyPath: keyPath] = node
        
        if let inverseKeyPath = inverseKeyPath {
            node[keyPath: inverseKeyPath].append(object)
        }
    }
}

fileprivate struct DocumentColorRelationship<T>: PendingRelationship where T: AnyObject {
    var object: T
    var keyPath: ReferenceWritableKeyPath<T, DocumentColor?>
    var colorID: DocumentColor.ID
    
    func resolve(nodes: [Node.ID : Node], documentColors: [DocumentColor.ID : DocumentColor], documentGradients: [DocumentGradient.ID : DocumentGradient]) {
        guard let color = documentColors[colorID] else {
            assertionFailure("""
                Failed to resolve color relationship. No Document Color found with id \
                \(colorID).
                """
            )
            return
        }
        object[keyPath: keyPath] = color
    }
}

fileprivate struct DocumentGradientRelationship<T>: PendingRelationship where T: AnyObject {
    var object: T
    var keyPath: ReferenceWritableKeyPath<T, DocumentGradient?>
    var gradientID: DocumentGradient.ID
    
    func resolve(nodes: [Node.ID : Node], documentColors: [DocumentColor.ID : DocumentColor], documentGradients: [DocumentGradient.ID : DocumentGradient]) {
        guard let gradient = documentGradients[gradientID] else {
            assertionFailure("""
                Failed to resolve gradient relationship. No Document Gradient found with id \
                \(gradientID).
                """
            )
            return
        }
        object[keyPath: keyPath] = gradient
    }
}

// MARK: CodingUserInfoKey

extension CodingUserInfoKey {
    public static let decodingCoordinator = CodingUserInfoKey(rawValue: "decodingCoordinator")!
}
