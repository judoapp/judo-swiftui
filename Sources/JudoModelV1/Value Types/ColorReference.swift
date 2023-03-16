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
import SwiftUI

/// A reference to a color, either an inline custom one or a reference to a document color.
///
/// Used as a value type, despite being a class; this is only a class to accommodate for decoding coordination.
public final class ColorReference: Codable, Equatable, Hashable, Dependable, NSCopying, ObservableObject {
    public static func == (lhs: ColorReference, rhs: ColorReference) -> Bool {
        return lhs.referenceType == rhs.referenceType &&
            lhs.documentColor == rhs.documentColor &&
            lhs.customColor == rhs.customColor &&
            lhs.colorName == rhs.colorName
    }

    public enum ReferenceType: String, Codable {
        case system
        case custom
        case document
    }

    public let referenceType: ReferenceType
    
    /// Only when referenceType == .system.
    public let colorName: String?
    
    /// Only when referenceType == .document.
    ///
    /// (Note: will be nil until decode coordination occurs.)
    @Dependent public var documentColor: DocumentColor?
    
    /// Only when referenceType == .custom.
    public var customColor: ColorValue?

    public init() {
        self.referenceType = .system
        self.colorName = "systemFill"
    }
    
    public init(systemName: String) {
        self.referenceType = .system
        self.colorName = systemName
    }
    
    public init(documentColor: DocumentColor) {
        self.referenceType = .document
        self.documentColor = documentColor
        self.colorName = nil
    }
    
    public init(customColor: ColorValue) {
        self.referenceType = .custom
        self.customColor = customColor
        self.colorName = nil
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.referenceType)
        hasher.combine(self.colorName)
        hasher.combine(self.documentColor)
        hasher.combine(self.customColor)
    }
    
    // MARK: Computed Properties
    
    public var systemColorName: String? {
        get {
            guard case .system = self.referenceType else { return nil }
            return colorName
        }
    }
    
    // MARK: Default
    
    public static var `default`: ColorReference {
        ColorReference(systemName: "clear")
    }
    
    // MARK: NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        switch referenceType {
        case .custom:
            return ColorReference(customColor: customColor!)
        case .document:
            return ColorReference(documentColor: documentColor!)
        case .system:
            return ColorReference(systemName: colorName!)
        }
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case referenceType
        case colorName
        case documentColorID
        case customColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.referenceType = try container.decode(ReferenceType.self, forKey: .referenceType)
        self.colorName = try container.decodeIfPresent(String.self, forKey: .colorName)
        self.customColor = try container.decodeIfPresent(ColorValue.self, forKey: .customColor)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        if let documentColorID = try container.decodeIfPresent(DocumentColor.ID.self, forKey: .documentColorID) {
            coordinator.registerColorRelationship(colorID: documentColorID, to: self, keyPath: \.documentColor)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.referenceType, forKey: .referenceType)
        try container.encodeIfPresent(self.colorName, forKey: .colorName)
        try container.encodeIfPresent(self.documentColor?.id, forKey: .documentColorID)
        try container.encodeIfPresent(self.customColor, forKey: .customColor)
    }
}


