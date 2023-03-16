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

/// A reference to a gradient, either an inline custom one or a reference to a document gradient.
///
/// Used as a value type, despite being a class; this is only a class to accommodate for decoding coordination.
public final class GradientReference: Codable, Equatable, Hashable, Dependable, ObservableObject {
    public enum ReferenceType: String, Codable {
        case custom
        case document
    }
    
    public let referenceType: ReferenceType
    
    /// Only when referenceType == .document.
    ///
    /// (Note: will be nil until decode coordination occurs.)
    @Dependent public var documentGradient: DocumentGradient?
    
    /// Only when referenceType == .custom
    public var customGradient: GradientValue?
    
    public init() {
        self.referenceType = .custom
        self.customGradient = .default
    }
    
    public init(customGradient: GradientValue) {
        self.referenceType = .custom
        self.customGradient = customGradient
    }
    
    public init(documentGradient: DocumentGradient) {
        self.referenceType = .document
        self.documentGradient = documentGradient
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.referenceType)
        hasher.combine(self.customGradient)
        hasher.combine(self.documentGradient)
    }
    
    public static func == (lhs: GradientReference, rhs: GradientReference) -> Bool {
        return lhs.referenceType == rhs.referenceType &&
            lhs.customGradient == rhs.customGradient &&
            lhs.documentGradient == rhs.documentGradient
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case referenceType
        case customGradient
        case documentGradientID
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.referenceType = try container.decode(ReferenceType.self, forKey: .referenceType)
        self.customGradient = try container.decodeIfPresent(GradientValue.self, forKey: .customGradient)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        if let documentGradientID = try container.decodeIfPresent(DocumentGradient.ID.self, forKey: .documentGradientID) {
            coordinator.registerGradientRelationship(gradientID: documentGradientID, to: self, keyPath: \.documentGradient)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.referenceType, forKey: .referenceType)
        try container.encodeIfPresent(self.customGradient, forKey: .customGradient)
        try container.encodeIfPresent(self.documentGradient?.id, forKey: .documentGradientID)
    }
}

extension GradientReference {
    public var humanName: String {
        switch self.referenceType {
        case .custom:
            return "Custom"
        case .document:
            return self.documentGradient?.name ?? "Unknown"
        }
    }
}
