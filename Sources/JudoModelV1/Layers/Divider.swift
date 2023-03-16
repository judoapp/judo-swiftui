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

public final class Divider: Layer {
    public var backgroundColor = ColorReference(systemName: "separator") { willSet { objectWillChange.send() } }
    
    required public init() {
        super.init()
    }
    
    // MARK: Traits
    
    override public var traits: Traits {
        [
            .paddable,
            .frameable,
            .stackable,
            .offsetable,
            .metadatable,
            .codePreview
        ]
    }
    
    // MARK: Assets
    
    override public func colorReferences() -> [Binding<ColorReference>] {
        let backgroundColorBinding = Binding<ColorReference> {
            self.backgroundColor
        } set: { newValue in
            self.backgroundColor = newValue
        }
        
        return super.colorReferences() + [backgroundColorBinding]
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let divider = super.copy(with: zone) as! Divider
        divider.backgroundColor = backgroundColor.copy() as! ColorReference
        return divider
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case backgroundColor
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundColor = try container.decode(ColorReference.self, forKey: .backgroundColor)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try super.encode(to: encoder)
    }
}
