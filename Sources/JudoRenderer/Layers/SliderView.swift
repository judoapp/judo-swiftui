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

struct SliderView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    @ComponentValue private var labelValue: TextValue
    @OptionalComponentValue private var minLabelValue: TextValue?
    @OptionalComponentValue private var maxLabelValue: TextValue?
    @ComponentValue private var value: NumberValue
    @OptionalComponentValue private var minValue: NumberValue?
    @OptionalComponentValue private var maxValue: NumberValue?
    @OptionalComponentValue private var step: NumberValue?

    init(slider: JudoModel.Slider) {
        self.labelValue = slider.label
        self.minLabelValue = slider.minLabel
        self.maxLabelValue = slider.maxLabel
        self.value = slider.value
        self.minValue = slider.minValue
        self.maxValue = slider.maxValue
        self.step = slider.step
    }

    var body: some SwiftUI.View {
        if $minLabelValue == nil && $maxLabelValue == nil {
            // Slider without min and max labels
            slider
        } else {
            // Slider with min and max labels
            sliderWithMaxMinLabels
        }
    }

    @ViewBuilder
    private var slider: some View {
        switch (range, $step) {
        case (.some(let range), .some(let step)):
            SwiftUI.Slider(value: valueBinding, in: range, step: step) {
                SwiftUI.Text($labelValue ?? "")
            }
        case (.some(let range), .none):
            SwiftUI.Slider(value: valueBinding, in: range) {
                SwiftUI.Text($labelValue ?? "")
            }
            /// Note: It is not possible to have a slider with a step and no range.
        default:
            SwiftUI.Slider(value: valueBinding) {
                SwiftUI.Text($labelValue ?? "")
            }
        }
    }

    @ViewBuilder
    private var sliderWithMaxMinLabels: some View {
        switch (range, $step) {
        case (.some(let range), .some(let step)):
            SwiftUI.Slider(value: valueBinding, in: range, step: step) {
                SwiftUI.Text($labelValue ?? "")
            } minimumValueLabel: {
                SwiftUI.Text($minLabelValue ?? "")
            } maximumValueLabel: {
                SwiftUI.Text($maxLabelValue ?? "")
            }
        case (.some(let range), .none):
            SwiftUI.Slider(value: valueBinding, in: range) {
                SwiftUI.Text($labelValue ?? "")
            } minimumValueLabel: {
                SwiftUI.Text($minLabelValue ?? "")
            } maximumValueLabel: {
                SwiftUI.Text($maxLabelValue ?? "")
            }
        default:
            SwiftUI.Slider(value: valueBinding) {
                SwiftUI.Text($labelValue ?? "")
            } minimumValueLabel: {
                SwiftUI.Text($minLabelValue ?? "")
            } maximumValueLabel: {
                SwiftUI.Text($maxLabelValue ?? "")
            }
        }
    }

    private var valueBinding: Binding<Double> {
        Binding {
            $value ?? 0
        } set: { newValue in
            if case .property(let name) = value {
                switch componentState.bindings[name]?.value {
                case .number:
                    componentState.bindings[name]?.value = .number(newValue)
                case .text:
                    componentState.bindings[name]?.value = .text(newValue.description)
                default:
                    break
                }
            }
        }
    }

    private var range: ClosedRange<Double>? {
        guard let minValue = $minValue, let maxValue = $maxValue else { return nil }
        if minValue < maxValue {
            return minValue...maxValue
        } else {
            return nil
        }
    }
}
