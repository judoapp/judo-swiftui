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

public enum PropertyValue: Codable, Hashable {
    case text(String)
    case number(Double)
    case boolean(Bool)
    case image(ImageReference)
    case component(UUID)
    case video(Video)
    case computed(ComputedPropertyValue)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(PropertyValue.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .text:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.TextCodingKeys.self, forKey: .text)
            self = PropertyValue.text(try nestedContainer.decode(String.self, forKey: PropertyValue.TextCodingKeys._0))
        case .number:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.NumberCodingKeys.self, forKey: .number)
            self = PropertyValue.number(try nestedContainer.decode(Double.self, forKey: PropertyValue.NumberCodingKeys._0))
        case .boolean:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.BooleanCodingKeys.self, forKey: .boolean)
            self = PropertyValue.boolean(try nestedContainer.decode(Bool.self, forKey: PropertyValue.BooleanCodingKeys._0))
        case .image:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.ImageCodingKeys.self, forKey: .image)
            self = PropertyValue.image(try nestedContainer.decode(ImageReference.self, forKey: PropertyValue.ImageCodingKeys._0))
        case .component:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.ComponentCodingKeys.self, forKey: .component)
            self = PropertyValue.component(try nestedContainer.decode(UUID.self, forKey: PropertyValue.ComponentCodingKeys._0))
        case .video:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.VideoCodingKeys.self, forKey: .video)
            
            let meta = decoder.userInfo[.meta] as! Meta
            switch meta.version {
            case ..<21:
                self = .video(Video(url: try nestedContainer.decode(String.self, forKey: ._0)))
            default:
                self = PropertyValue.video(try nestedContainer.decode(Video.self, forKey: PropertyValue.VideoCodingKeys._0))
            }
        case .computed:
            let nestedContainer = try container.nestedContainer(keyedBy: PropertyValue.ComputedCodingKeys.self, forKey: .computed)
            self = PropertyValue.computed(try nestedContainer.decode(ComputedPropertyValue.self, forKey: PropertyValue.ComputedCodingKeys._0))
        }
    }
}
