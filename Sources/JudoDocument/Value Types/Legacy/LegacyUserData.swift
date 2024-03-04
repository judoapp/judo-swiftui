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

struct LegacyUserData: Decodable {
    var expandedNodeIDs: Set<UUID>
    var zoomScale: CGFloat
    var scrollOffset: CGPoint
    var previewLanguage: PreviewLanguage?
    var isDarkModeEnabled: Bool
    var isHighContrastModeEnabled: Bool
    var deviceSize: LegacyDeviceSize
    var deviceOrientation: Device.Orientation
    var contentSizeCategory: ContentSizeCategory
    var simulateSlowNetwork: Bool

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case expandedNodeIDs
        case zoomScale
        case scrollOffset
        case previewLanguage
        case isDarkModeEnabled
        case isHighContrastModeEnabled
        case deviceSize
        case deviceOrientation
        case contentSizeCategory
        case simulateSlowNetwork

        // Legacy
        case previewOperatingSystem
        case canvasScroll
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta

        expandedNodeIDs = try container.decode(Set<UUID>.self, forKey: .expandedNodeIDs)
        zoomScale = try container.decode(CGFloat.self, forKey: .zoomScale)

        switch meta.version {
        case ..<17:
            if let canvasScroll = try container.decodeIfPresent(CGRect.self, forKey: .canvasScroll) {
                scrollOffset = CGPoint(
                    x: 500_000 - canvasScroll.origin.x,
                    y: 500_000 - canvasScroll.origin.y
                )
            } else {
                scrollOffset = .zero
            }
        default:
            scrollOffset = try container.decode(CGPoint.self, forKey: .scrollOffset)
        }

        previewLanguage = try container.decodeIfPresent(PreviewLanguage.self, forKey: .previewLanguage)
        isDarkModeEnabled = try container.decode(Bool.self, forKey: .isDarkModeEnabled)
        isHighContrastModeEnabled = try container.decode(Bool.self, forKey: .isHighContrastModeEnabled)
        deviceSize = try container.decode(LegacyDeviceSize.self, forKey: .deviceSize)
        deviceOrientation = try container.decode(Device.Orientation.self, forKey: .deviceOrientation)
        contentSizeCategory = try container.decode(ContentSizeCategory.self, forKey: .contentSizeCategory)
        simulateSlowNetwork = try container.decode(Bool.self, forKey: .simulateSlowNetwork)
    }
}
