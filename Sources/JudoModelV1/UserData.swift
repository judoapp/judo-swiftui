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
import CoreGraphics
import SwiftUI

public final class UserData: Codable, ObservableObject {
    public static let maxZoomScale = CGFloat(256)
    public static let minZoomScale = CGFloat(0.01)

    @Published public var expandedNodes = [Node]()
    @Published public var zoomScale = CGFloat(1.0)
    @Published public var previewLanguage: PreviewLanguage?

    @Published public var isDarkModeEnabled = false
    @Published public var isHighContrastModeEnabled = false
    @Published public var previewOperatingSystem = OperatingSystem.iOS
    @Published public var deviceSize = DeviceSize.medium
    @Published public var deviceOrientation = DeviceOrientation.portrait
    @Published public var contentSizeCategory = ContentSizeCategory.large
    @Published public var simulateSlowNetwork = false

    public init() { }

    public enum OperatingSystem: String, Codable {
        case iOS
        case android
    }

    public enum DeviceOrientation: String, Codable {
        case portrait
        case landscape

        public mutating func toggle() {
            switch self {
            case .portrait:
                self = .landscape
            case .landscape:
                self = .portrait
            }
        }
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case expandedNodeIDs
        case scrollOffset
        case zoomScale
        case previewLanguage
        case previewOperatingSystem
        case isDarkModeEnabled
        case isHighContrastModeEnabled
        case deviceSize
        case deviceOrientation
        case contentSizeCategory
        case simulateSlowNetwork
    }

    public init(from decoder: Decoder) throws {
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        let container = try decoder.container(keyedBy: CodingKeys.self)
        zoomScale = try container.decode(CGFloat.self, forKey: .zoomScale)
        previewLanguage = try container.decodeIfPresent(PreviewLanguage.self, forKey: .previewLanguage)

        if coordinator.documentVersion >= 7 {
            previewOperatingSystem = try container.decode(OperatingSystem.self, forKey: .previewOperatingSystem)
        } else {
            previewOperatingSystem = OperatingSystem.iOS
        }

        isDarkModeEnabled = try container.decode(Bool.self, forKey: .isDarkModeEnabled)
        isHighContrastModeEnabled = try container.decode(Bool.self, forKey: .isHighContrastModeEnabled)

        if coordinator.documentVersion >= 7 {
            deviceSize = try container.decode(DeviceSize.self, forKey: .deviceSize)
        } else {
            deviceSize = .medium
        }

        if coordinator.documentVersion >= 8 {
            deviceOrientation = try container.decode(DeviceOrientation.self, forKey: .deviceOrientation)
        } else {
            deviceOrientation = .portrait
        }

        contentSizeCategory = try container.decode(ContentSizeCategory.self, forKey: .contentSizeCategory)
        simulateSlowNetwork = try container.decode(Bool.self, forKey: .simulateSlowNetwork)

        let expandedNodeIDs = try container.decode([Node.ID].self, forKey: .expandedNodeIDs)
        coordinator.registerOneToManyRelationship(
            nodeIDs: expandedNodeIDs,
            to: self,
            keyPath: \.expandedNodes
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expandedNodes.map(\.id), forKey: .expandedNodeIDs)
        try container.encode(zoomScale, forKey: .zoomScale)
        try container.encodeIfPresent(previewLanguage, forKey: .previewLanguage)
        try container.encode(previewOperatingSystem, forKey: .previewOperatingSystem)
        try container.encode(isDarkModeEnabled, forKey: .isDarkModeEnabled)
        try container.encode(isHighContrastModeEnabled, forKey: .isHighContrastModeEnabled)
        try container.encode(deviceSize, forKey: .deviceSize)
        try container.encode(deviceOrientation, forKey: .deviceOrientation)
        try container.encode(contentSizeCategory, forKey: .contentSizeCategory)
        try container.encode(simulateSlowNetwork, forKey: .simulateSlowNetwork)
    }
}
