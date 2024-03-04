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

public enum Override: Codable, Hashable {
    case text(Variable<String>)
    case number(Variable<Double>)
    case boolean(Variable<Bool>)
    case image(Variable<ImageReference>)
    case component(Variable<UUID>)
    case video(Variable<Video>)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(Override.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .text:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.TextCodingKeys.self, forKey: .text)
            self = Override.text(try nestedContainer.decode(Variable<String>.self, forKey: Override.TextCodingKeys._0))
        case .number:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.NumberCodingKeys.self, forKey: .number)
            self = Override.number(try nestedContainer.decode(Variable<Double>.self, forKey: Override.NumberCodingKeys._0))
        case .boolean:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.BooleanCodingKeys.self, forKey: .boolean)
            self = Override.boolean(try nestedContainer.decode(Variable<Bool>.self, forKey: Override.BooleanCodingKeys._0))
        case .image:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.ImageCodingKeys.self, forKey: .image)
            self = Override.image(try nestedContainer.decode(Variable<ImageReference>.self, forKey: Override.ImageCodingKeys._0))
        case .component:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.ComponentCodingKeys.self, forKey: .component)
            self = Override.component(try nestedContainer.decode(Variable<UUID>.self, forKey: Override.ComponentCodingKeys._0))
        case .video:
            let nestedContainer = try container.nestedContainer(keyedBy: Override.VideoCodingKeys.self, forKey: .video)

            let meta = decoder.userInfo[.meta] as! Meta
            switch meta.version {
            case ..<21:
                let text = try nestedContainer.decode(Variable<String>.self, forKey: Override.VideoCodingKeys._0)
                let binding: Variable<Video>.Binding?
                switch text.binding {
                case .data(let keyPath):
                    binding = .data(keyPath: keyPath)
                case .property(let name):
                    binding = .property(name: name)
                case .fetchedImage, .none:
                    binding = nil
                }

                self = Override.video(Variable(Video(url: text.constant), binding: binding))
            default:
                self = Override.video(try nestedContainer.decode(Variable<Video>.self, forKey: Override.VideoCodingKeys._0))
            }
        }
    }
}
