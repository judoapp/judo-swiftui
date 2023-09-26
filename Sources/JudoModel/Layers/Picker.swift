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

    @Published public var label: Variable<String> = ""
    @Published public var textSelection: Variable<String>?
    @Published public var numberSelection: Variable<Double>?
    @Published @objc public dynamic var options: [PickerOption] = []
    @Published public var pickerType: PickerType = .text

    required public init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.label, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.textSelection, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.numberSelection, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        
        for option in options {
            option.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        }
        
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }

    // MARK: NSCopying

    override public func copy(with zone: NSZone? = nil) -> Any {
        let layerCopy = super.copy(with: zone) as! Self
        layerCopy.label = label
        layerCopy.textSelection = textSelection
        layerCopy.numberSelection = numberSelection
        layerCopy.options = options
        layerCopy.pickerType = pickerType
        return layerCopy
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case textSelection
        case numberSelection
        case options
        case pickerType
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator


        switch coordinator.documentVersion {
        case ..<17:
            label = try Variable(container.decode(LegacyTextValue.self, forKey: .label))
            if let value = try container.decodeIfPresent(LegacyTextValue.self, forKey: .textSelection) {
                textSelection = Variable(value)
                pickerType = .text
            }
            if let numberValue = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .numberSelection) {
                numberSelection = Variable(numberValue)
                pickerType = .number
            }
        default:
            label = try container.decode(Variable<String>.self, forKey: .label)
            textSelection = try container.decodeIfPresent(Variable<String>.self, forKey: .textSelection)
            numberSelection = try container.decodeIfPresent(Variable<Double>.self, forKey: .numberSelection)
            pickerType = try container.decode(PickerType.self, forKey: .pickerType)
        }

        options = try container.decode([PickerOption].self, forKey: .options)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(textSelection, forKey: .textSelection)
        try container.encode(numberSelection, forKey: .numberSelection)
        try container.encode(options, forKey: .options)
        try container.encode(pickerType, forKey: .pickerType)
        try super.encode(to: encoder)
    }
}

// MARK: - PickerOption

public final class PickerOption: JudoObject {
    @Published public var title: Variable<String>?
    @Published public var icon: Variable<ImageReference>?
    @Published public var textValue: Variable<String>?
    @Published public var numberValue: Variable<Double>?

    public init(title: Variable<String>?, icon: Variable<ImageReference>? = nil, textValue: Variable<String>) {
        self.title = title
        self.icon = icon
        self.textValue = textValue
        super.init()
    }
    
    public init(title: Variable<String>?, icon: Variable<ImageReference>? = nil, numberValue: Variable<Double>) {
        self.title = title
        self.icon = icon
        self.numberValue = numberValue
        super.init()
    }
    
    public required init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.title, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.icon, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.textValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        updateVariable(\.numberValue, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
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
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator


        switch coordinator.documentVersion {
        case ..<17:
            if let icon = try container.decode(LegacyImageValue?.self, forKey: .icon) {
                self.icon = Variable(icon)
            }

            if let title = try container.decode(LegacyTextValue?.self, forKey: .title) {
                self.title = Variable(title)
            }

            if let textValue = try container.decode(LegacyTextValue?.self, forKey: .textValue) {
                self.textValue = Variable(textValue)
            }

            if let value = try container.decodeIfPresent(LegacyNumberValue.self, forKey: .numberValue) {
                numberValue = Variable(value)
            }
        default:
            icon = try container.decode(Variable<ImageReference>?.self, forKey: .icon)
            title = try container.decode(Variable<String>?.self, forKey: .title)
            textValue = try container.decode(Variable<String>?.self, forKey: .textValue)
            numberValue = try container.decodeIfPresent(Variable<Double>.self, forKey: .numberValue)
        }

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

public enum PickerType: Codable {
    case text
    case number
}
