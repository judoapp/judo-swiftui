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
    public var expandedNodeIDs: Set<Node.ID>
    public var zoomScale: CGFloat
    public var canvasScroll: CGRect?
    public var previewLanguage: PreviewLanguage?
    public var isDarkModeEnabled: Bool
    public var isHighContrastModeEnabled: Bool
    public var deviceSize: DeviceSize
    public var deviceOrientation: DeviceOrientation
    public var contentSizeCategory: ContentSizeCategory
    public var simulateSlowNetwork: Bool
    
    public init(
        expandedNodeIDs: Set<Node.ID>,
        zoomScale: CGFloat,
        canvasScroll: CGRect?,
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
        self.canvasScroll = canvasScroll
        self.previewLanguage = previewLanguage
        self.isDarkModeEnabled = isDarkModeEnabled
        self.isHighContrastModeEnabled = isHighContrastModeEnabled
        self.deviceSize = deviceSize
        self.deviceOrientation = deviceOrientation
        self.contentSizeCategory = contentSizeCategory
        self.simulateSlowNetwork = simulateSlowNetwork
    }

    private enum CodingKeys: String, CodingKey {
        case expandedNodeIDs
        case zoomScale
        case canvasScroll
        case previewLanguage
        case isDarkModeEnabled
        case isHighContrastModeEnabled
        case deviceSize
        case deviceOrientation
        case contentSizeCategory
        case simulateSlowNetwork
        
        // Legacy
        case previewOperatingSystem
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        expandedNodeIDs = try container.decode(Set<Node.ID>.self, forKey: .expandedNodeIDs)
        zoomScale = try container.decode(CGFloat.self, forKey: .zoomScale)
        canvasScroll = try container.decodeIfPresent(CGRect.self, forKey: .canvasScroll)
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
        try container.encodeIfPresent(canvasScroll, forKey: .canvasScroll)
        try container.encodeIfPresent(previewLanguage, forKey: .previewLanguage)
        try container.encode(isDarkModeEnabled, forKey: .isDarkModeEnabled)
        try container.encode(isHighContrastModeEnabled, forKey: .isHighContrastModeEnabled)
        try container.encode(deviceSize, forKey: .deviceSize)
        try container.encode(deviceOrientation, forKey: .deviceOrientation)
        try container.encode(contentSizeCategory, forKey: .contentSizeCategory)
        try container.encode(simulateSlowNetwork, forKey: .simulateSlowNetwork)
        
        // Legacy
        try container.encode("iOS", forKey: .previewOperatingSystem)
    }
}
