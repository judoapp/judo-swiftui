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

import SwiftUI
import os.log

/// A layer that displays an image.
public final class AsyncImage: Layer, Modifiable {

    public enum Scale: Codable, CaseIterable, Comparable, CustomStringConvertible, ExpressibleByIntegerLiteral, Identifiable {
        case one
        case two
        case three

        public init(integerLiteral value: IntegerLiteralType) {
            switch value {
            case 1:
                self = .one
            case 2:
                self = .two
            case 3:
                self = .three
            default:
                fatalError("Invalid value")
            }
        }

        public var description: String {
            switch self {
            case .one:
                return "1x"
            case .two:
                return "2x"
            case .three:
                return "3x"
            }
        }

        public var scale: CGFloat {
            switch self {
            case .one:
                return 1
            case .two:
                return 2
            case .three:
                return 3
            }
        }

        public var id: Self {
            self
        }
    }

    @Published public var url: TextValue = ""
    @Published public var scale: Scale = .one
    @Published public var errorState: Bool = false

    public override class var humanName: String {
        "Async Image"
    }

    required public init() {
        super.init()
        setupInitialState()
    }

    private func setupInitialState() {
        // Content
        let contentContainer = Container(name: "Content")
        contentContainer.parent = self
        let image = Image()
        image.value = .fetchedImage
        image.parent = contentContainer
        contentContainer.children = [image]

        // Placeholder
        let placeholderContainer = Container(name: "Placeholder")
        placeholderContainer.parent = self

        let rectangle = Rectangle()
        rectangle.shapeStyle = .flat(ColorReference(systemName: "label"))
        let opacity = OpacityModifier()
        opacity.opacity = 0.16

        opacity.parent = rectangle
        rectangle.children = [opacity]

        rectangle.parent = placeholderContainer
        placeholderContainer.children = [rectangle]

        children = [contentContainer, placeholderContainer]
    }

    public var content: Container {
        children[0] as! Container
    }

    public var placeholder: Container {
        children[1] as! Container
    }

    // MARK: Hierarchy

    override public var isLeaf: Bool {
        false
    }

    override public func canAcceptChild<T: Node>(ofType type: T.Type) -> Bool {
        false
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        return super.description
    }
        
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .insettable,
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .shadowable,
            .fadeable,
            .layerable,
            .actionable,
            .accessible,
            .metadatable,
            .lockable
        ]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let image = super.copy(with: zone) as! Self
        image.url = url
        image.scale = scale
        image.errorState = errorState
        return image
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case scale
        case url
        case errorState
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(AsyncImage.Scale.self, forKey: .scale)
        url = try container.decode(TextValue.self, forKey: .url)
        errorState = try container.decode(Bool.self, forKey: .errorState)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        try container.encode(url, forKey: .url)
        try container.encode(errorState, forKey: .errorState)
        try super.encode(to: encoder)
    }

}
