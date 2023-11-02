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

public struct ColorReference: Codable, Hashable {
    public var referenceType: ColorReferenceType
    public var colorName: String?
    public var documentColorID: UUID?
    public var customColor: ColorValue?
    
    public init(systemName: String) {
        self.referenceType = .system
        self.colorName = systemName
    }
    
    public init(documentColor: DocumentColor) {
        self.referenceType = .document
        self.documentColorID = documentColor.id
        self.colorName = nil
    }
    
    public init(customColor: ColorValue) {
        self.referenceType = .custom
        self.customColor = customColor
        self.colorName = nil
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
        self.referenceType = try container.decode(ColorReferenceType.self, forKey: .referenceType)
        self.colorName = try container.decodeIfPresent(String.self, forKey: .colorName)
        self.documentColorID = try container.decodeIfPresent(UUID.self, forKey: .documentColorID)
        self.customColor = try container.decodeIfPresent(ColorValue.self, forKey: .customColor)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.referenceType, forKey: .referenceType)
        try container.encodeIfPresent(self.colorName, forKey: .colorName)
        try container.encodeIfPresent(self.documentColorID, forKey: .documentColorID)
        try container.encodeIfPresent(self.customColor, forKey: .customColor)
    }
}
