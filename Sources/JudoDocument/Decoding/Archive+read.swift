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
import XCAssetsKit
import ZIPFoundation

extension Archive {
    func extractMeta(with decoder: JSONDecoder) throws -> Meta {
        guard let metaFile = self["meta.json"], metaFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        let metaData: Data
        let meta: Meta
        do {
            metaData = try self.extract(entry: metaFile)
            meta = try decoder.decode(Meta.self, from: metaData)
        } catch {
            throw CocoaError(.fileReadUnknown)
        }
        return meta
    }
    
    func extractAssets() throws -> XCAssetCatalog {
        let folderName = "Assets.xcassets"
        let xcassetEntries = self.filter({ $0.path.hasPrefix(folderName + "/") })
        if xcassetEntries.isEmpty {
            return XCAssetCatalog()
        }

        let temporaryDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle", isDirectory: true).standardized
        try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
        for entry in xcassetEntries {
            _ = try self.extract(entry, to: temporaryDirectoryURL.appendingPathComponent("/" + entry.path))
        }
        let xcassetsPath = temporaryDirectoryURL.appendingPathComponent(folderName)
        return XCAssetCatalog(at: xcassetsPath)
    }
    
    func extractStrings() throws -> StringsCatalog {
        let entriesByPath: [String: Entry] = self.reduce(into: [:]) { result, entry in
            result[entry.path] = entry
        }

        let stringsTableEntries = entriesByPath.filter { (path, entry) in
            (path.starts(with: "localization/") || path.starts(with: "/localization/")) && entry.type == .file && (path as NSString).pathExtension == "json"
        }

        let decoder = JSONDecoder()
        return try stringsTableEntries.reduce(into: StringsCatalog()) { result, element in
            let localeIdentifier = LocaleIdentifier((element.key as NSString).lastPathComponent)
            let table = try decoder.decode(StringsTable.self, from: try self.extract(entry: element.value))
            result[localeIdentifier] = table
        }
    }
    
    func extractFonts() throws -> Set<FontValue> {
        let entriesByPath: [String: Entry] = self.reduce(into: [:]) { result, entry in
            result[entry.path] = entry
        }

        let fontsEntries = entriesByPath.filter { (path, entry) in
            (path.starts(with: "fonts/") || path.starts(with: "/fonts/")) && entry.type == .file
        }

        return try fontsEntries.reduce(into: []) { result, element in
            guard element.value.type == .file else {
                throw CocoaError(.fileReadUnknown)
            }

            let fileURL = URL(fileURLWithPath: element.key)
            let fontData = try self.extract(entry: element.value)
            let fontValue = try FontValue(data: fontData, fileExtension: fileURL.pathExtension)
            result.insert(fontValue)
        }
    }
    
    func extractUserData(with decoder: JSONDecoder) throws -> UserData {
        guard let userFile = self["user.json"], userFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        do {
            let data = try self.extract(entry: userFile)
            return try decoder.decode(UserData.self, from: data)
        } catch {
            throw CocoaError(.fileReadUnknown)
        }
    }
    
    func extractDocumentNode(with decoder: JSONDecoder) throws -> DocumentNode {
        guard let documentFile = self["document.json"], documentFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        do {
            let data = try self.extract(entry: documentFile)
            return try decoder.decode(DocumentNode.self, from: data)
        } catch {
            throw CocoaError(.fileReadUnknown)
        }
    }
    
    func extractNodeArchive(with decoder: JSONDecoder) throws -> NodeArchive {
        guard let documentFile = self["document.json"], documentFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        do {
            let data = try self.extract(entry: documentFile)
            return try decoder.decode(NodeArchive.self, from: data)
        } catch {
            throw CocoaError(.fileReadUnknown)
        }
    }
    
    /// Extract the entire ZIP Entry (assuming it is a File entry) into a single buffer.
    func extract(entry: Entry) throws -> Data {
        var buffer = Data(count: Int(entry.uncompressedSize))
        var position = 0

        // the CRC32 check is extremely slow in debug builds, so skip it.
        #if DEBUG
        let skipCRC32 = true
        #else
        let skipCRC32 = false
        #endif

        // despite the closure, this is not asynchronous.
        let _ = try self.extract(entry, skipCRC32: skipCRC32) { chunk in
            let endPos = Swift.min(position + chunk.count, Int(entry.uncompressedSize))
            let targetRange: Range<Data.Index> = position..<endPos
            if targetRange.count > 0 {
                buffer[targetRange] = chunk
            }
            position = endPos
        }
        return buffer
    }
}
