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
import CoreGraphics
import SwiftUI
import XCAssetsKit
import ZIPFoundation

public struct DocumentNode: Node {
    public var id: UUID
    public var name: String?
    public var children: [Node]
    public var deletedNodes: [Node]
    public var colors: [DocumentColor]
    public var gradients: [DocumentGradient]
    public var fonts: [DocumentFont]
    public var assets: XCAssetCatalog
    public var strings: StringsCatalog
    public var importedFonts: Set<FontValue>
    public var userData: UserData
    
    public init() {
        self.id = UUID()
        self.name = nil
        self.children = []
        self.deletedNodes = []
        self.colors = []
        self.gradients = []
        self.fonts = []
        self.assets = XCAssetCatalog()
        self.strings = StringsCatalog()
        self.importedFonts = []
        self.userData = UserData()
    }
    
    public init(id: UUID, name: String?, children: [Node], deletedNodes: [Node], colors: [DocumentColor], gradients: [DocumentGradient], fonts: [DocumentFont], assets: XCAssetCatalog, strings: StringsCatalog, importedFonts: Set<FontValue>, userData: UserData) {
        self.id = id
        self.name = name
        self.children = children
        self.deletedNodes = deletedNodes
        self.colors = colors
        self.gradients = gradients
        self.fonts = fonts
        self.assets = assets
        self.strings = strings
        self.importedFonts = importedFonts
        self.userData = userData
    }
    
    public var allNodes: [Any] {
        children + deletedNodes
    }

    // MARK: Read and Write
    
    public static func read(from data: Data, errorOnForwardsCompatibility: Bool = false) throws -> DocumentNode {
        let archive = try Archive.init(data: data, accessMode: .read)

        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )

        // Meta
        let meta = try archive.extractMeta(with: decoder)
        
        if meta.version < 13 { // Judo v1
            throw VersionCompatibilityError.backwardsIncompatible
        }

        if meta.compatibilityVersion > Meta.current.version {
            throw VersionCompatibilityError.forwardsIncompatible
        }

        if meta.compatibilityVersion <= Meta.current.version,
            meta.version > Meta.current.version,
           errorOnForwardsCompatibility {
            throw VersionCompatibilityError.forwardsCompatible
        }
        
        decoder.userInfo[.meta] = meta
        
        // Assets
        decoder.userInfo[.assets] = try archive.extractAssets()
        
        // String
        decoder.userInfo[.strings] = try archive.extractStrings()
        
        // Fonts
        decoder.userInfo[.fonts] = try archive.extractFonts()
        
        // User Data
        decoder.userInfo[.userData] = try archive.extractUserData(with: decoder)

        // Document
        return try archive.extractDocumentNode(with: decoder)
    }
    
    #if os(macOS)
    public func data(previewImage: NSImage?) throws -> Data {
        let archive = try Archive(accessMode: .create)
        
        if let previewImage {
            try archive.insertPreviewImage(previewImage)
        }
        
        return try data(archive: archive)
    }
    #else
    public func data(previewImage: UIImage?) throws -> Data {
        let archive = try Archive(accessMode: .create)
        if let previewImage {
            try archive.insertPreviewImage(previewImage)
        }
        
        return try data(archive: archive)
    }
    #endif
    
    private func data(archive: Archive) throws -> Data {
        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )
        
        // Meta
        try archive.addFile(
            path: "meta.json",
            data: try encoder.encode(Meta.current),
            compressionMethod: .deflate
        )
        
        // Asssets
        try archive.insertAssets(assets)
        
        // Strings
        try archive.insertStrings(strings)
        
        // Fonts
        try archive.insertFonts(fonts: importedFonts)
        
        // User Data
        try archive.addFile(
            path: "user.json",
            data: try encoder.encode(userData),
            compressionMethod: .deflate
        )
        
        // Document
        try archive.addFile(
            path: "document.json",
            data: try encoder.encode(self),
            compressionMethod: .deflate
        )

        guard let data = archive.data else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        return data
    }
    
    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case children
        case deletedNodes
        case colors
        case gradients
        case fonts
        
        // ..<18
        case nodes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<18:
            id = UUID()
            name = nil
            children = try container.decodeNodes(forKey: .nodes)
            
            if container.contains(.deletedNodes) {
                deletedNodes = try container.decodeNodes(forKey: .deletedNodes)
            } else {
                deletedNodes = []
            }
        default:
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            children = try container.decodeNodes(forKey: .children)
            deletedNodes = try container.decodeNodes(forKey: .deletedNodes)
        }

        colors = try container.decode([DocumentColor].self, forKey: .colors)
        gradients = try container.decode([DocumentGradient].self, forKey: .gradients)
        fonts = try container.decode([DocumentFont].self, forKey: .fonts)
        
        // Ancillory data
        assets = decoder.userInfo[.assets] as! XCAssetCatalog
        strings = decoder.userInfo[.strings] as! StringsCatalog
        importedFonts = decoder.userInfo[.fonts] as! Set<FontValue>
        userData = decoder.userInfo[.userData] as! UserData
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeNodes(children, forKey: .children)
        try container.encodeNodes(deletedNodes, forKey: .deletedNodes)
        try container.encode(colors, forKey: .colors)
        try container.encode(gradients, forKey: .gradients)
        try container.encode(fonts, forKey: .fonts)
    }
}
