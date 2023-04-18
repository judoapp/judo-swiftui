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

public final class XCAssets: Identifiable {

    public enum Kind: String, CaseIterable {
        case imageSet

        public var folderExtension: String {
            switch self {
            case .imageSet:
                return "imageset"
            }
        }
    }

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

    public func addImageSet(name imageSetName: String) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if FileManager.default.fileExists(atPath: imageSetURL.path) {
            return
        }

        do {
            try FileManager.default.createDirectory(at: imageSetURL, withIntermediateDirectories: true)
            let contents = try JSONEncoder().encode(ImageSet(images: []))
            let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
            try contents.write(to: contentsURL, options: .atomic)
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
            try addImageSet(name: imageSetName)
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

            do {
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
                    imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
                }
            }

            // Update Contents.json
            imageSet.images += [
                ImageSet.Image(
                    appearances: appearance == nil ? nil : [appearance!],
                    filename: filename,
                    scale: scale
                )
            ]

            try JSONEncoder().encode(imageSet).write(to: contentsURL, options: .atomic)

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
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return
        }

        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        var imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
        imageSet.images.removeAll { imageContents in
            imageContents.filename == filename
        }
        try JSONEncoder().encode(imageSet).write(to: contentsURL, options: .atomic)
        try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(filename))
    }

    public func removeImage(imageSet imageSetName: String, ofScale scale: ImageSet.Image.Scale) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return
        }

        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        var imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
        let toRemove = imageSet.images.filter { $0.scale == scale }
        imageSet.images.removeAll { imageContents in
            imageContents.scale == scale
        }
        try JSONEncoder().encode(imageSet).write(to: contentsURL, options: .atomic)
        for item in toRemove {
            try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(item.filename))
        }
    }

    public func removeImage(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale) throws {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return
        }

        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        var imageSet = try JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe))
        let toRemove = images(imageSet: imageSetName, appearance: appearance, scale: scale)
        imageSet.images.removeAll { image in
            toRemove.contains(where: { $0.scale == image.scale && $0.appearances == image.appearances })
        }

        // Update imageSet
        try JSONEncoder().encode(imageSet).write(to: contentsURL, options: .atomic)

        for item in toRemove where !imageSet.images.contains(where: { $0.filename == item.filename }) {
            // Ensure we only remove the file if it is not being used by another image
            try FileManager.default.removeItem(at: imageSetURL.appendingPathComponent(item.filename))
        }
    }

    public func images(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: ImageSet.Image.Scale) -> [ImageSet.Image] {
        let imageSetURL = storageSetURL(kind: .imageSet, name: imageSetName)
        if !FileManager.default.fileExists(atPath: imageSetURL.path) {
            return []
        }

        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        guard let imageSet = try? JSONDecoder().decode(ImageSet.self, from: Data(contentsOf: contentsURL, options: .mappedIfSafe)) else {
            return []
        }

        return imageSet.images
            .filter {
                // find all with matching scale
                $0.scale == scale
            }
            .filter {
                // find all with matching appearances
                // If we have no appearances on the ImageSet
                if $0.appearances == nil && appearance == nil {
                    return true
                }

                if let appearances = $0.appearances, let appearance {
                    return appearances.contains(appearance)
                }
                return false
            }
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

    public func storageSetURL(kind: Kind, name: String) -> URL {
        storageURL.appendingPathComponent(name + "." + kind.folderExtension)
    }

    public func allNames(_ kind: Kind) -> [String] {
        var result: [String] = []
        do {
            for item in try FileManager.default.contentsOfDirectory(atPath: storageURL.path) {
                if item.hasSuffix("." + kind.folderExtension) {
                    result.append((item as NSString).deletingPathExtension)
                }
            }
        } catch {
            assertionFailure()
            return []
        }

        return result
    }

    public func enumerate(_ element: (_ kind: Kind, _ name: String) -> Void) throws {
        for kind in Kind.allCases {
            for pathItem in try FileManager.default.contentsOfDirectory(atPath: storageURL.path) {
                if pathItem.hasSuffix("." + kind.folderExtension) {
                    let name = (pathItem as NSString).deletingPathExtension
                    element(kind, name)
                }
            }
        }
    }
}

private extension Data {
    var sha256String: String {
        SHA256.hash(data: self).compactMap { String(format: "%02x", $0) }.joined()
    }
}
