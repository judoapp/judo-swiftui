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

    public init(assets: XCAssets = XCAssets()) {
        self.assets = assets
    }

    public func write(atPath path: String) throws {
        try assets.write(atPath: path)
    }

    public func image(named name: String, appearance: Appearances?, scale: Scale, strictAppearanceMatch: Bool, searchOtherScale: Bool) -> (data: Data, scale: CGFloat)? {
        assets.image(imageSet: name, appearance: appearance, scale: scale, strictAppearanceMatch: strictAppearanceMatch, searchOtherScale: searchOtherScale)
    }

    /// Returns array of image assets names
    public func allImageNames() -> [String] {
        assets.allNames(.imageSet)
    }

    public func uniqueAssetName(proposedName name: String) -> String {
        var finalName = name
        var i = 1
        while allImageNames().contains(finalName) {
            finalName = name + " (\(i))"
            i += 1
        }
        return finalName
    }

    public func insertImage(_ data: Data, named name: String, appearance: Appearances?, scale: Scale) throws {
        try assets.insertImage(
            imageSet: name,
            data: data,
            appearance: appearance,
            scale: scale
        )

        Task { @MainActor in
            objectWillChange.send()
        }
    }

    public func insertImage(from fileURL: URL, named name: String, appearance: Appearances?, scale: Scale) throws {
        precondition(fileURL.isFileURL)

        let data = try Data(contentsOf: fileURL)
        try insertImage(data,
            named: name,
            appearance: appearance,
            scale: scale
        )
    }

    @MainActor
    public func removeImage(fromImageSet named: String, appearance: ImageSet.Image.Appearances?, scale: Scale) throws {
        try assets.removeImage(fromImageSet: named, appearance: appearance, scale: scale)
        objectWillChange.send()
    }
}
