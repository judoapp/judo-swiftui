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

public struct PresentationDetent: Codable {

    public enum StandardDetent: Codable {
        case medium
        case large
    }

    public var id: UUID
    public var standardDetent: StandardDetent?
    public var fractionValue: Variable<Double>?
    public var heightValue: Variable<Double>?

    public init(
        id: UUID,
        standardDetent: StandardDetent?,
        fractionValue: Variable<Double>?,
        heightValue: Variable<Double>?
    ) {
        self.id = id
        self.standardDetent = standardDetent
        self.fractionValue = fractionValue
        self.heightValue = heightValue
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case standardDetent
        case fractionValue
        case heightValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.standardDetent = try container.decodeIfPresent(StandardDetent.self, forKey: .standardDetent)
        self.fractionValue = try container.decodeIfPresent(Variable<Double>.self, forKey: .fractionValue)
        self.heightValue = try container.decodeIfPresent(Variable<Double>.self, forKey: .heightValue)

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(standardDetent, forKey: .standardDetent)
        try container.encodeIfPresent(fractionValue, forKey: .fractionValue)
        try container.encodeIfPresent(heightValue, forKey: .heightValue)
    }
}
