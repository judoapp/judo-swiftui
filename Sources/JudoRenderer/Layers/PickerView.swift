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

import JudoModel
import SwiftUI

struct PickerView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    @ComponentValue private var labelValue: TextValue
    @OptionalComponentValue private var textSelection: TextValue?
    @OptionalComponentValue private var numberSelection: NumberValue?
    private var isTextBinding: Bool
    private var options: [PickerOption]

    init(picker: JudoModel.Picker) {
        self.labelValue = picker.label
        self.textSelection = picker.textSelection
        self.numberSelection = picker.numberSelection
        self.isTextBinding = picker.textSelection != nil
        self.options = picker.options

    }

    var body: some View {
        if isTextBinding {
            SwiftUI.Picker($labelValue ?? "", selection: stringSelectionBinding) {
                ForEach(options) { option in
                    row(for: option)
                        .tag(textTag(option))
                }
            }
        } else {
            SwiftUI.Picker($labelValue ?? "", selection: numberSelectionBinding) {
                ForEach(options) { option in
                    row(for: option)
                        .tag(numberTag(option))
                }
            }
        }
    }

    @ViewBuilder
    private func row(for option: PickerOption) -> some View {
        let title = text(option.title)
        if let imageReference = option.icon?.resolve(data: data, componentState: componentState) {
            if title.isEmpty {
                ImageReferenceView(
                    imageReference: imageReference,
                    resizing: .none,
                    renderingMode: .original,
                    symbolRenderingMode: .monochrome
                )
            } else {
                SwiftUI.Label {
                    SwiftUI.Text(title)
                } icon: {
                    ImageReferenceView(
                        imageReference: imageReference,
                        resizing: .none,
                        renderingMode: .original,
                        symbolRenderingMode: .monochrome
                    )
                }
            }
        } else {
            SwiftUI.Text(title)
        }
    }

    private var stringSelectionBinding: Binding<String?> {
        Binding {
            $textSelection
        } set: { newValue in
            guard let newValue else {
                return
            }
            
            if case let .property(name, _) = textSelection {
                componentState.bindings[name]?.value = .text(newValue)
            }
        }
    }

    private func text(_ value: TextValue?) -> String {
        value?.resolve(data: data, componentState: componentState) ?? ""
    }

    private func textTag(_ option: PickerOption) -> String? {
        if let textValue = option.textValue {
            return textValue.resolve(data: data, componentState: componentState)
        }
        
        return nil
    }

    private var numberSelectionBinding: Binding<Double?> {
        Binding {
            $numberSelection
        } set: { newValue in
            guard let newValue else {
                return
            }
            
            if case let .property(name) = numberSelection {
                componentState.bindings[name]?.value = .number(newValue)
            }
        }
    }

    private func numberTag(_ option: PickerOption) -> Double? {
        if let numberValue = option.numberValue {
            return numberValue.resolve(data: data, componentState: componentState)
        }
        
        return nil
    }
}
