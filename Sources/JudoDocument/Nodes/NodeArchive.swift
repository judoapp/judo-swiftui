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

public struct NodeArchive: Codable {
    public var nodes: [Node]
    public var referencedMainComponents: [MainComponentNode]
    public var colors: [DocumentColor]
    public var gradients: [DocumentGradient]
    public var fonts: [DocumentFont]
    public var assets: XCAssetCatalog
    
    public init(nodes: [Node], referencedMainComponents: [MainComponentNode], colors: [DocumentColor], gradients: [DocumentGradient], fonts: [DocumentFont], assets: XCAssetCatalog) {
        self.nodes = nodes
        self.referencedMainComponents = referencedMainComponents
        self.colors = colors
        self.gradients = gradients
        self.fonts = fonts
        self.assets = assets
    }
    // MARK: Read and Write
    
    public static func read(from data: Data) throws -> NodeArchive {
        let archive = try ZIPFoundation.Archive(data: data, accessMode: .read)
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )

        // Check Version Compatibility
        
        let meta = try archive.extractMeta(with: decoder)
        
        if meta.version < 13 { // Judo v1
            throw VersionCompatibilityError.backwardsIncompatible
        }

        if meta.compatibilityVersion > Meta.current.version {
            throw VersionCompatibilityError.forwardsIncompatible
        }

        // Ancillary Data
        decoder.userInfo[.meta] = meta
        decoder.userInfo[.assets] = try archive.extractAssets()

        // Extract node archive
        return try archive.extractNodeArchive(with: decoder)
    }

    public func data() throws -> Data {
        let archive = try Archive(accessMode: .create)
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
        case nodes
        case referencedMainComponents
        case colors
        case gradients
        case fonts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try container.decodeNodes(forKey: .nodes)
        referencedMainComponents = try container.decode([MainComponentNode].self, forKey: .referencedMainComponents)
        colors = try container.decode([DocumentColor].self, forKey: .colors)
        gradients = try container.decode([DocumentGradient].self, forKey: .gradients)
        fonts = try container.decode([DocumentFont].self, forKey: .fonts)
        assets = decoder.userInfo[.assets] as! XCAssetCatalog
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNodes(nodes, forKey: .nodes)
        try container.encodeNodes(referencedMainComponents, forKey: .referencedMainComponents)
        try container.encode(colors, forKey: .colors)
        try container.encode(gradients, forKey: .gradients)
        try container.encode(fonts, forKey: .fonts)
    }
}
