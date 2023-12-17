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

struct ConditionalView: SwiftUI.View {
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState
    var conditional: ConditionalNode

    var body: some SwiftUI.View {
        if allConditionsSatisfied {
            ForEach(conditional.children, id: \.id) {
                NodeView(node: $0)
            }
        }
    }

    private var allConditionsSatisfied: Bool {
        conditional.conditions.allSatisfy { condition in
            condition.isSatisfied(
                data: data,
                propertyValues: componentState.propertyValues
            )
        }
    }
}
