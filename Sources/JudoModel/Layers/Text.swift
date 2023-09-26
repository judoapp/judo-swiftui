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

import CoreGraphics
import SwiftUI

public final class Text: Layer, Modifiable {
    @Published public dynamic var value: Variable<String> = "Hello, world!"

    required public init() {
        super.init()
    }
    
    public init(_ key: String) {
        self.value = Variable(key)
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.value, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: Description
    
    override public var description: String {
        if let name = name {
            return name
        }
        
        let trimmed = value.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(20))
    }
    
    override public class var keyPathsAffectingDescription: Set<String> {
        ["text"]
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
    
    // MARK: Assets
    
    override public func strings() -> [String] {
        var strings = super.strings()

        if !value.isBinding {
            strings.append(value.constant)
        }
        
        return strings
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let text = super.copy(with: zone) as! Text
        text.value = self.value
        return text
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case value
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<17:
            value = try Variable(container.decode(LegacyTextValue.self, forKey: .value))
        default:
            value = try container.decode(Variable<String>.self, forKey: .value)
        }
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try super.encode(to: encoder)
    }
}
