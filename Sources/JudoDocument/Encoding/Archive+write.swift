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

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

import Foundation
import XCAssetsKit
import ZIPFoundation

extension Archive {
    #if os(macOS)
    func insertPreviewImage(_ previewImage: NSImage) throws {
        guard let cgImage = previewImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = previewImage.size
        
        guard let data = imageRep.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        try addFile(path: "preview.png", data: data, compressionMethod: .none)
    }
    #else
    func insertPreviewImage(_ previewImage: UIImage) throws {
        guard let data = previewImage.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        try addFile(path: "preview.png", data: data, compressionMethod: .none)
    }
    #endif
    
    func insertAssets(_ assets: XCAssetCatalog, predicate: (_ kind: AssetKind, _ assetName: String) -> Bool = { _, _ in true }) throws {
        // Create assets directory in a temporary location
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true).standardized
        try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
        let xcassetsDirectoryPath = temporaryDirectoryURL.appendingPathComponent("Assets.xcassets").path

        // Write assets to temporary location
        try assets.write(to: xcassetsDirectoryPath)

        // Add xcassets content to the archive
        let directoryEnumerator = FileManager.default.enumerator(atPath: xcassetsDirectoryPath)
        while let filePath = directoryEnumerator?.nextObject() as? String {
            let assetDirectoryName = ((filePath as NSString).pathComponents[0] as NSString)
            let assetDirectoryPathExtension = assetDirectoryName.pathExtension
            let assetName = (assetDirectoryName as NSString).deletingPathExtension

            if let kind = AssetKind(folderExtension: assetDirectoryPathExtension) {
                if predicate(kind, assetName) {
                    try addEntry(
                        with: "Assets.xcassets/" + filePath,
                        fileURL: URL(fileURLWithPath: xcassetsDirectoryPath + "/" + filePath),
                        compressionMethod: .none
                    )
                }
            } else {
                try addEntry(
                    with: "Assets.xcassets/" + filePath,
                    fileURL: URL(fileURLWithPath: xcassetsDirectoryPath + "/" + filePath),
                    compressionMethod: .none
                )
            }
        }

        // Cleanup. Remove temporary directory
        try FileManager.default.removeItem(at: temporaryDirectoryURL)
    }
    
    func insertStrings(_ strings: StringsCatalog) throws {
        let encoder = JSONEncoder()
        let entries: [String: Data] = try strings.reduce(into: [:]) { result, entry in
            let (localeIdentifier, table) = entry
            result["\(localeIdentifier).json"] = try encoder.encode(table)
        }
        
        try insertFiles(path: "localization", items: entries)
    }
    
    func insertFonts(fonts: Set<FontValue>) throws {
        let items: [String: Data] = fonts.reduce(into: [:]) { result, fontValue in
            result[fontValue.filename] = fontValue.data
        }
        
        try insertFiles(path: "fonts", items: items, compressionMethod: .none)
    }
    
    func addFile(path: String, data: Data, compressionMethod: CompressionMethod = .deflate) throws {
        let size = data.count
        try self.addEntry(
            with: path,
            type: Entry.EntryType.file,
            uncompressedSize: Int64(size),
            modificationDate: Date(),
            compressionMethod: compressionMethod,
            bufferSize: defaultWriteChunkSize,
            progress: nil,
            provider: { (position, bufferSize) -> Data in
                let position = Int(truncatingIfNeeded: position)
                let upperBound = Swift.min(size, position + bufferSize)
                let range = Range(uncheckedBounds: (lower: position, upper: upperBound))
                return data.subdata(in: range)
           }
        )
    }

    func insertFiles(path: String, items: [String : Data], compressionMethod: CompressionMethod = .deflate) throws {
        try items.forEach { (name, data) in
            try self.addFile(path: NSString.path(withComponents: [path, name]), data: data, compressionMethod: compressionMethod)
        }
    }
}
