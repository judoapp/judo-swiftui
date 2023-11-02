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

public struct GradientReference: Codable, Hashable {
    public var referenceType: GradientReferenceType
    public var documentGradientID: UUID?
    public var customGradient: GradientValue?
    
    public init(customGradient: GradientValue) {
        self.referenceType = .custom
        self.customGradient = customGradient
    }
    
    public init(documentGradient: DocumentGradient) {
        self.referenceType = .document
        self.documentGradientID = documentGradient.id
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case referenceType
        case customGradient
        case documentGradientID
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.referenceType = try container.decode(GradientReferenceType.self, forKey: .referenceType)
        self.customGradient = try container.decodeIfPresent(GradientValue.self, forKey: .customGradient)
        self.documentGradientID = try container.decodeIfPresent(UUID.self, forKey: .documentGradientID)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.referenceType, forKey: .referenceType)
        try container.encodeIfPresent(self.customGradient, forKey: .customGradient)
        try container.encodeIfPresent(self.documentGradientID, forKey: .documentGradientID)
    }
}
