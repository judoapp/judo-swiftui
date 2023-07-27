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

public final class Picker: Layer, Modifiable {

    @Published public var label: TextValue = ""
    @Published public var textSelection: TextValue?
    @Published public var numberSelection: NumberValue?
    @Published @objc public dynamic var options: [PickerOption] = []

    required public init() {
        super.init()
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let layerCopy = super.copy(with: zone) as! Self
        layerCopy.label = label
        layerCopy.textSelection = textSelection
        layerCopy.numberSelection = numberSelection
        layerCopy.options = options
        return layerCopy
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case textSelection
        case numberSelection
        case options
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decode(TextValue.self, forKey: .label)
        textSelection = try container.decodeIfPresent(TextValue.self, forKey: .textSelection)
        numberSelection = try container.decodeIfPresent(NumberValue.self, forKey: .numberSelection)
        options = try container.decode([PickerOption].self, forKey: .options)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(textSelection, forKey: .textSelection)
        try container.encode(numberSelection, forKey: .numberSelection)
        try container.encode(options, forKey: .options)
        try super.encode(to: encoder)
    }
}

// MARK: - PickerOption

public final class PickerOption: JudoObject {
    @Published public var title: TextValue?
    @Published public var icon: ImageValue?
    @Published public var textValue: TextValue?
    @Published public var numberValue: NumberValue?

    public init(title: TextValue?, icon: ImageValue? = nil, textValue: TextValue) {
        self.title = title
        self.icon = icon
        self.textValue = textValue
        super.init()
    }
    
    public init(title: TextValue?, icon: ImageValue? = nil, numberValue: NumberValue) {
        self.title = title
        self.icon = icon
        self.numberValue = numberValue
        super.init()
    }
    
    public required init() {
        super.init()
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let pickerOption = super.copy(with: zone) as! PickerOption
        pickerOption.title = title
        pickerOption.icon = icon
        pickerOption.textValue = textValue
        pickerOption.numberValue = numberValue
        return pickerOption
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case title
        case icon
        case textValue
        case numberValue
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(TextValue?.self, forKey: .title)
        icon = try container.decode(ImageValue?.self, forKey: .icon)
        textValue = try container.decode(TextValue?.self, forKey: .textValue)
        numberValue = try container.decode(NumberValue?.self, forKey: .numberValue)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(textValue, forKey: .textValue)
        try container.encode(numberValue, forKey: .numberValue)
        try super.encode(to: encoder)
    }
}
