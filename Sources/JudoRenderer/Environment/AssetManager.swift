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

final class AssetManager {
    private let assets: XCAssetCatalog

    class CacheData {
        let data: Data
        let scale: CGFloat

        init(data: Data, scale: CGFloat) {
            self.data = data
            self.scale = scale
        }
    }

    private let cache = NSCache<NSString, CacheData>()

    init(assets: XCAssetCatalog = XCAssetCatalog()) {
        self.assets = assets
    }

    func image(
        named imageSetName: String,
        appearance: XCAssetsKit.ImageSet.Image.Appearances?,
        scale: XCAssetsKit.ImageSet.Image.Scale,
        strictAppearanceMatch: Bool,
        searchOtherScale: Bool
    ) -> (data: Data, scale: CGFloat)? {
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
}
