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
import CryptoKit
import CoreImage
import UniformTypeIdentifiers

public final class XCAssetCatalog: Identifiable {

    public let id: String = UUID().uuidString

    // Storage behind the instance
    private let storageURL: URL
    private let isManaged: Bool

    public init() {
        self.storageURL = FileManager.default.temporaryDirectory.appendingPathComponent(id + ".xcassets")
        self.isManaged = true
        try! FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        try! JSONEncoder().encode(Info()).write(to: storageURL.appendingPathComponent("Contents.json"))
    }

    public init(at url: URL) {
        self.storageURL = url
        self.isManaged = false
    }

    deinit {
        if isManaged {
            try? FileManager.default.removeItem(at: storageURL)
        }
    }

    public func asset(kind: AssetKind, name: String) -> (any Asset)? {
        availableAssets(kind).first(where: { $0.name == name })?.asset
    }

    public func availableAssets(_ kind: AssetKind? = nil) -> [(name: String, asset: any Asset)] {
        guard let allObjects = FileManager.default.enumerator(atPath: storageURL.path)?.allObjects as? [String] else {
            return []
        }

        return allObjects.compactMap { path in
            let assetDirectoryURL = storageURL.appendingPathComponent(path)

            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: assetDirectoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue == true else {
                return nil
            }

            let directoryName = (path as NSString).lastPathComponent
            let assetName = (directoryName as NSString).deletingPathExtension
            let directoryPathExtension = (directoryName as NSString).pathExtension

            switch AssetKind(folderExtension: directoryPathExtension) {
            case .imageSet where kind == .imageSet || kind == nil:
                let contentsURL = assetDirectoryURL.appendingPathComponent("Contents.json")
                if let imageSet = try? JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL)) {
                    return (name: assetName, asset: imageSet)
                }
            default:
                assertionFailure("Not supported")
                return nil
            }

            return nil
        }
    }

    public func addImageSet(name imageSetName: String, sortingIndex: Double) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if FileManager.default.fileExists(atPath: imageSetURL.path) {
            return
        }

        do {
            try FileManager.default.createDirectory(at: imageSetURL, withIntermediateDirectories: true)
            let imageSet = ImageSet(sortingIndex: sortingIndex)
            try save(asset: imageSet, name: imageSetName)
        } catch {
            try? FileManager.default.removeItem(at: imageSetURL)
            throw error
        }
    }

    public func removeImageSet(name imageSetName: String) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if FileManager.default.fileExists(atPath: imageSetURL.path) {
            try FileManager.default.removeItem(at: imageSetURL)
        }
    }

    public func addImage(imageSet imageSetName: String, data: Data, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            try addImageSet(name: imageSetName, sortingIndex: Date.timeIntervalSinceReferenceDate)
        }

        var filename = data.sha256String + "@\(scale.description)"

        if let imageSource = CGImageSourceCreateWithData(data as NSData, nil),
           let utiString = CGImageSourceGetType(imageSource) as? String,
           let preferredFilenameExtension = UTType(utiString)?.preferredFilenameExtension
        {
            filename += "." + preferredFilenameExtension
        }

        let fileURL = imageSetURL.appendingPathComponent(filename)
        do {
            let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
            var imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
            // Delete image from the slot that exactly match inserting image
            // Don't use ImageSet.image(named:appearance:scale) as it find the closest match
            let foundImage = imageSet.images.first { image in
                if appearance == nil, image.appearances == nil, image.scale == scale {
                    return true
                } else if let appearance = appearance, image.appearances?.contains(appearance) == true, image.scale == scale {
                    return true
                }

                return false
            }

            if let foundImage {
                try removeImage(imageSet: imageSetName, filename: foundImage.filename)

                // refresh asset from storage
                imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
            }

            // Update Contents.json
            imageSet.images.append(
                ImageSet.Image(
                    appearances: appearance == nil ? nil : [appearance!],
                    filename: filename,
                    scale: scale
                )
            )
            try save(asset: imageSet, name: imageSetName)

            // Overwrite file content
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try data.write(to: fileURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }
    }

    public func removeImage(imageSet imageSetName: String, filename: String) throws {
        guard var imageSet = asset(kind: .imageSet, name: imageSetName) as? ImageSet else {
            return
        }

        imageSet.images.removeAll { imageContents in
            imageContents.filename == filename
        }

        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(filename))

        try save(asset: imageSet, name: imageSetName)
    }

    public func removeImage(imageSet imageSetName: String, ofScale scale: ImageSet.Image.Scale) throws {
        guard var imageSet = asset(kind: .imageSet, name: imageSetName) as? ImageSet else {
            return
        }

        let toRemove = imageSet.images.filter { $0.scale == scale }
        imageSet.images.removeAll { imageContents in
            imageContents.scale == scale
        }

        try save(asset: imageSet, name: imageSetName)

        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        for item in toRemove {
            try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(item.filename))
        }
    }

    public func removeImage(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale) throws {
        guard var imageSet = asset(kind: .imageSet, name: imageSetName) as? ImageSet else {
            return
        }

        let toRemove = imageSet.images(appearance: appearance, scale: scale)
        imageSet.images.removeAll { image in
            toRemove.contains(where: { $0.scale == image.scale && $0.appearances == image.appearances })
        }

        // Update imageSet
        try save(asset: imageSet, name: imageSetName)

        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        for item in toRemove where !imageSet.images.contains(where: { $0.filename == item.filename }) {
            // Ensure we only remove the file if it is not being used by another image
            try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(item.filename))
        }
    }

    public func images(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale) -> [ImageSet.Image] {
        guard let imageSet = asset(kind: .imageSet, name: imageSetName) as? ImageSet else {
            return []
        }

        return imageSet.images(appearance: appearance, scale: scale)
    }

    /// All images
    public func images(imageSet imageSetName: String) -> [ImageSet.Image] {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return []
        }

        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        guard let imageSet = try? JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe)) else {
            return []
        }

        return imageSet.images
    }

    public func image(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale, strictAppearanceMatch: Bool, searchOtherScale: Bool) -> (fileURL: URL, scale: CGFloat, appearances: Set<ImageSet.Image.Appearances>?)? {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return nil
        }

        do {
            let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
            let imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
            let found = imageSet.image(for: appearance, scale: scale, strictAppearanceMatch: strictAppearanceMatch, searchOtherScale: searchOtherScale)
            if let found = found {
                let scale = found.scale ?? .one
                let appearances = found.appearances
                return (
                    fileURL: imageSetURL.appendingPathComponent("/" + found.filename),
                    scale: scale.scale,
                    appearances: appearances
                )
            }
        } catch {
            assertionFailure("Failed to get imageData \(error)")
            return nil
        }

        return nil
    }

    /// Build name.xcasset folder at path
    public func write(to path: String) throws {
        try FileManager.default.copyItem(at: storageURL, to: URL(fileURLWithPath: path))
    }

    public func storageSetURL(kind: AssetKind, name: String) -> URL {
        storageURL.appendingPathComponent(name + "." + kind.folderExtension)
    }

    private func save(asset: any Asset, name: String) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: name)
        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        try JSONEncoder().encode(asset).write(to: contentsURL, options: .atomic)
    }

}

private extension Data {
    var sha256String: String {
        SHA256.hash(data: self).compactMap { String(format: "%02x", $0) }.joined()
    }
}
