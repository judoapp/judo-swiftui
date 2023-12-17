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

import JudoDocument
import SwiftUI

struct SliderView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data

    var slider: JudoDocument.SliderNode

    var body: some SwiftUI.View {
        RealizeText(slider.minLabel ?? "") { minLabel in
            RealizeText(slider.maxLabel ?? "") { maxLabel in
                if minLabel.isEmpty && maxLabel.isEmpty {
                    // Slider without min and max labels
                    sliderView
                } else {
                    // Slider with min and max labels
                    sliderViewWithMaxMinLabels
                }
            }
        }
    }

    @ViewBuilder
    private var sliderView: some View {
        RealizeText(slider.label) { label in
            switch (range, slider.step?.forceResolve(propertyValues: componentState.propertyValues, data: data)) {
            case (.some(let range), .some(let step)):
                SwiftUI.Slider(value: valueBinding, in: range, step: step) {
                    SwiftUI.Text(label)
                }
            case (.some(let range), .none):
                SwiftUI.Slider(value: valueBinding, in: range) {
                    SwiftUI.Text(label)
                }
                /// Note: It is not possible to have a slider with a step and no range.
            default:
                SwiftUI.Slider(value: valueBinding) {
                    SwiftUI.Text(label)
                }
            }
        }
    }

    @ViewBuilder
    private var sliderViewWithMaxMinLabels: some View {
        RealizeText(slider.label) { label in
            RealizeText(slider.minLabel ?? "") { minLabel in
                RealizeText(slider.maxLabel ?? "") { maxLabel in
                    switch (range, slider.step?.forceResolve(propertyValues: componentState.propertyValues, data: data)) {
                    case (.some(let range), .some(let step)):
                        SwiftUI.Slider(value: valueBinding, in: range, step: step) {
                            SwiftUI.Text(label)
                        } minimumValueLabel: {
                            SwiftUI.Text(minLabel)
                        } maximumValueLabel: {
                            SwiftUI.Text(maxLabel)
                        }
                    case (.some(let range), .none):
                        SwiftUI.Slider(value: valueBinding, in: range) {
                            SwiftUI.Text(label)
                        } minimumValueLabel: {
                            SwiftUI.Text(minLabel)
                        } maximumValueLabel: {
                            SwiftUI.Text(maxLabel)
                        }
                    default:
                        SwiftUI.Slider(value: valueBinding) {
                            SwiftUI.Text(label)
                        } minimumValueLabel: {
                            SwiftUI.Text(minLabel)
                        } maximumValueLabel: {
                            SwiftUI.Text(maxLabel)
                        }
                    }
                }
            }
        }
    }

    private var valueBinding: Binding<Double> {
        Binding {
            slider.value.forceResolve(propertyValues: componentState.propertyValues, data: data)
        } set: { newValue in
            if case .property(let name) = slider.value.binding {
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
        guard let minValue = slider.minValue?.forceResolve(propertyValues: componentState.propertyValues, data: data), let maxValue = slider.maxValue?.forceResolve(propertyValues: componentState.propertyValues, data: data) else { return nil }
        if minValue < maxValue {
            return minValue...maxValue
        } else {
            return nil
        }
    }

}
