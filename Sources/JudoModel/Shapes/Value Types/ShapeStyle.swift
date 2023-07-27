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

public enum ShapeStyle: Codable, Hashable {
    public static var `default`: ShapeStyle = .flat(.init(systemName: "systemGray"))
    
    case flat(ColorReference)
    case gradient(GradientReference)

    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case color
        case gradient
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseName = try container.decode(String.self, forKey: .caseName)
        switch caseName {
        case "flat":
            let color = try container.decode(ColorReference.self, forKey: .color)
            self = .flat(color)
        case "gradient":
            let gradient = try container.decode(GradientReference.self, forKey: .gradient)
            self = .gradient(gradient)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .caseName,
                in: container,
                debugDescription: "Invalid value: \(caseName)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .flat(let color):
            try container.encode("flat", forKey: .caseName)
            try container.encode(color, forKey: .color)
        case .gradient(let gradient):
            try container.encode("gradient", forKey: .caseName)
            try container.encode(gradient, forKey: .gradient)
        }
    }
}
