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

public struct UserData: Codable {
    public var expandedNodeIDs: Set<UUID>
    public var zoomScale: CGFloat
    public var scrollOffset: CGPoint
    public var previewLanguage: PreviewLanguage?
    public var isDarkModeEnabled: Bool
    public var isHighContrastModeEnabled: Bool
    public var deviceSize: DeviceSize
    public var deviceOrientation: DeviceOrientation
    public var contentSizeCategory: ContentSizeCategory
    public var simulateSlowNetwork: Bool
    
    public init() {
        expandedNodeIDs = []
        zoomScale = 1.0
        scrollOffset = .zero
        previewLanguage = nil
        isDarkModeEnabled = false
        isHighContrastModeEnabled = false
        deviceSize = .medium
        deviceOrientation = .portrait
        contentSizeCategory = .large
        simulateSlowNetwork = false
    }
    
    public init(
        expandedNodeIDs: Set<UUID>,
        zoomScale: CGFloat,
        scrollOffset: CGPoint,
        previewLanguage: PreviewLanguage?,
        isDarkModeEnabled: Bool,
        isHighContrastModeEnabled: Bool,
        deviceSize: DeviceSize,
        deviceOrientation: DeviceOrientation,
        contentSizeCategory: ContentSizeCategory,
        simulateSlowNetwork: Bool
    ) {
        self.expandedNodeIDs = expandedNodeIDs
        self.zoomScale = zoomScale
        self.scrollOffset = scrollOffset
        self.previewLanguage = previewLanguage
        self.isDarkModeEnabled = isDarkModeEnabled
        self.isHighContrastModeEnabled = isHighContrastModeEnabled
        self.deviceSize = deviceSize
        self.deviceOrientation = deviceOrientation
        self.contentSizeCategory = contentSizeCategory
        self.simulateSlowNetwork = simulateSlowNetwork
    }
    
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

    public init(from decoder: Decoder) throws {
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
        deviceSize = try container.decode(DeviceSize.self, forKey: .deviceSize)
        deviceOrientation = try container.decode(DeviceOrientation.self, forKey: .deviceOrientation)
        contentSizeCategory = try container.decode(ContentSizeCategory.self, forKey: .contentSizeCategory)
        simulateSlowNetwork = try container.decode(Bool.self, forKey: .simulateSlowNetwork)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expandedNodeIDs, forKey: .expandedNodeIDs)
        try container.encode(zoomScale, forKey: .zoomScale)
        try container.encode(scrollOffset, forKey: .scrollOffset)
        try container.encodeIfPresent(previewLanguage, forKey: .previewLanguage)
        try container.encode(isDarkModeEnabled, forKey: .isDarkModeEnabled)
        try container.encode(isHighContrastModeEnabled, forKey: .isHighContrastModeEnabled)
        try container.encode(deviceSize, forKey: .deviceSize)
        try container.encode(deviceOrientation, forKey: .deviceOrientation)
        try container.encode(contentSizeCategory, forKey: .contentSizeCategory)
        try container.encode(simulateSlowNetwork, forKey: .simulateSlowNetwork)
    }
}
