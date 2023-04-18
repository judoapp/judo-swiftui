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

public final class Assets: ObservableObject {

    public typealias Scale = XCAssetsKit.ImageSet.Image.Scale
    public typealias Appearances = XCAssetsKit.ImageSet.Image.Appearances

    private let assets: XCAssets
    private let trashURL: URL

    class CacheData {
        let data: Data
        let scale: CGFloat

        init(data: Data, scale: CGFloat) {
            self.data = data
            self.scale = scale
        }
    }

    private let cache = NSCache<NSString, CacheData>()

    public init(assets: XCAssets) {
        self.assets = assets
        self.trashURL = FileManager.default.temporaryDirectory.appendingPathComponent(assets.id + ".trash")
        try! FileManager.default.createDirectory(at: trashURL, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: trashURL)
    }

    public func write(to path: String) throws {
        try assets.write(to: path)
    }

    public func image(named imageSetName: String, appearance: Appearances?, scale: Scale, strictAppearanceMatch: Bool, searchOtherScale: Bool) -> (data: Data, scale: CGFloat)? {
        if let result = assets.image(imageSet: imageSetName, appearance: appearance, scale: scale, strictAppearanceMatch: strictAppearanceMatch, searchOtherScale: searchOtherScale) {
            let cacheKey = "\(imageSetName)\(String(describing: result.appearances))\(result.scale)\(strictAppearanceMatch)\(searchOtherScale)" as NSString
            if let cacheData = cache.object(forKey: cacheKey) {
                return (data: cacheData.data, scale: cacheData.scale)
            }
            if let data = try? Data(contentsOf: result.fileURL, options: .alwaysMapped) {
                cache.setObject(CacheData(data: data, scale: result.scale), forKey: cacheKey)
                return (data: data, scale: result.scale)
            }

            assertionFailure("Can't locate file \(result.fileURL.path) ")
            return nil
        }

        return nil
    }

    /// Returns array of image assets names
    public func allImageSetNames() -> [String] {
        assets.allNames(.imageSet)
    }

    public func countImages(imageSet imageSetName: String) -> Int {
        assets.images(imageSet: imageSetName).count
    }

    public func uniqueAssetName(proposedName name: String) -> String {
        var finalName = name
        var i = 1
        while allImageSetNames().contains(finalName) {
            finalName = name + " (\(i))"
            i += 1
        }
        return finalName
    }

    public func addImage(_ fileURL: URL, imageSet imageSetName: String, appearance: Appearances?, scale: Scale, undoManager: UndoManager?) throws {
        precondition(fileURL.isFileURL)
        try addImage(Data(contentsOf: fileURL, options: .mappedIfSafe),
                     imageSet: imageSetName,
                     appearance: appearance,
                     scale: scale,
                     undoManager: undoManager
        )
    }

    public func addImage(_ data: Data, imageSet imageSetName: String, appearance: Appearances?, scale: Scale, undoManager: UndoManager?) throws {
        cache.removeAllObjects()

        let imageExists = !assets.images(imageSet: imageSetName, appearance: appearance, scale: scale).isEmpty
        guard !imageExists else {
            return
        }

        try assets.addImage(
            imageSet: imageSetName,
            data: data,
            appearance: appearance,
            scale: scale
        )

        undoManager?.registerUndo(withTarget: self) { [weak self] assets in
            guard let self = self else { return }

            try? assets.removeImage(imageSet: imageSetName, appearance: appearance, scale: scale, undoManager: undoManager)

            undoManager?.registerUndo(withTarget: self) { obj in
                try? obj.addImage(data, imageSet: imageSetName, appearance: appearance, scale: scale, undoManager: undoManager)

                Task { @MainActor in
                    self.objectWillChange.send()
                }
            }

            Task { @MainActor in
                self.objectWillChange.send()
            }
        }

        Task { @MainActor in
            objectWillChange.send()
        }
    }

    public func removeImageSet(_ imageSetName: String, undoManager: UndoManager?) throws {
        cache.removeAllObjects()

        if let undoManager = undoManager {
            let imageAssetURL = assets.storageSetURL(kind: .imageSet, name: imageSetName)
            let imageSetTrashURL = trashURL.appendingPathComponent(UUID().uuidString)

            undoManager.registerUndo(withTarget: assets) { [weak self] assets in
                guard let self = self else { return }
                let imageSetURL = assets.storageSetURL(kind: .imageSet, name: imageSetName)
                try? FileManager.default.moveItem(at: imageSetTrashURL, to: imageSetURL)

                undoManager.registerUndo(withTarget: self) { obj in
                    try? obj.removeImageSet(imageSetName, undoManager: undoManager)

                    Task { @MainActor in
                        self.objectWillChange.send()
                    }
                }

                Task { @MainActor in
                    self.objectWillChange.send()
                }
            }

            try FileManager.default.moveItem(at: imageAssetURL, to: imageSetTrashURL)
        } else {
            try assets.removeImageSet(name: imageSetName)
        }

        Task { @MainActor in
            objectWillChange.send()
        }
    }

    public func removeImage(imageSet imageSetName: String, appearance: ImageSet.Image.Appearances?, scale: Scale, undoManager: UndoManager?) throws {
        cache.removeAllObjects()
        
        if let undoManager = undoManager {
            let imagesToRemove = assets.images(imageSet: imageSetName, appearance: appearance, scale: scale)

            var trashedImages: [URL] = []
            // Copy to trash and remove
            for img in imagesToRemove {
                let fromURL = assets.storageSetURL(kind: .imageSet, name: imageSetName).appendingPathComponent(img.filename)
                let toTrashURL = trashURL.appendingPathComponent(UUID().uuidString)
                try FileManager.default.copyItem(at: fromURL, to: toTrashURL)
                try assets.removeImage(imageSet: imageSetName, filename: img.filename)
                trashedImages.append(toTrashURL)
            }

            undoManager.registerUndo(withTarget: assets) { [weak self] assets in
                guard let self = self else { return }

                // Re-add image file
                for trashedImageURL in trashedImages {
                    do {
                        try assets.addImage(
                            imageSet: imageSetName,
                            data: Data(contentsOf: trashedImageURL),
                            appearance: appearance,
                            scale: scale
                        )

                        try FileManager.default.removeItem(at: trashedImageURL)

                        undoManager.registerUndo(withTarget: self) { obj in
                            try? obj.removeImage(imageSet: imageSetName, appearance: appearance, scale: scale, undoManager: undoManager)

                            Task { @MainActor in
                                self.objectWillChange.send()
                            }
                        }
                    } catch {
                        assertionFailure()
                    }
                }

                Task { @MainActor in
                    self.objectWillChange.send()
                }
            }
        } else {
            try assets.removeImage(imageSet: imageSetName, appearance: appearance, scale: scale)
        }

        Task { @MainActor in
            objectWillChange.send()
        }
    }
}
