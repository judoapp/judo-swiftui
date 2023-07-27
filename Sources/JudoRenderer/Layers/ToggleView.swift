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

struct ToggleView: SwiftUI.View {
    @EnvironmentObject private var componentState: ComponentState
    @Environment(\.data) private var data
    
    @ComponentValue private var isOnValue: BooleanValue
    @ComponentValue private var labelValue: TextValue

    init(toggle: JudoModel.Toggle) {
        self.isOnValue = toggle.isOn
        self.labelValue = toggle.label
    }

    var body: some SwiftUI.View {
        SwiftUI.Toggle($labelValue ?? "", isOn: isOnBinding)
    }

    private var isOnBinding: Binding<Bool> {
        Binding {
            $isOnValue ?? false
        } set: { newValue in
            if case .property(let name) = isOnValue {
                componentState.bindings[name]?.value = .boolean(newValue)
            }
        }

    }
}
