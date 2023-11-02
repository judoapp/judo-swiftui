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

struct NodeView: SwiftUI.View {
    private var node: Node
    
    init(node: Node) {
        self.node = node
    }
    
    var body: some SwiftUI.View {
        content
            .modifier(
                NodeViewModifier(node: node)
            )
    }
    
    @ViewBuilder private var content: some SwiftUI.View {
        switch node {
        case let button as JudoDocument.ButtonNode:
            ButtonView(button: button)
        case let capsule as JudoDocument.CapsuleNode:
            CapsuleView(capsule: capsule)
        case let circle as JudoDocument.CircleNode:
            CircleView(circle: circle)
        case let collection as CollectionNode:
          CollectionView(collection: collection)
        case let componentInstance as ComponentInstanceNode:
            ComponentInstanceView(componentInstance: componentInstance)
        case let conditional as ConditionalNode:
          ConditionalView(conditional: conditional)
        case let dataSource as DataSourceNode:
          DataSourceView(dataSource: dataSource)
        case let divider as JudoDocument.DividerNode:
            DividerView(divider: divider)
        case let ellipse as JudoDocument.EllipseNode:
            EllipseView(ellipse: ellipse)
        case let form as JudoDocument.FormNode:
            FormView(form: form)
        case let stack as JudoDocument.HStackNode:
            HStackView(stack: stack)
        case let image as JudoDocument.ImageNode:
            ImageView(image: image)
        case let image as JudoDocument.AsyncImageNode:
            AsyncImageView(image: image)
        case let navigationLink as JudoDocument.NavigationLinkNode:
            NavigationLinkView(navigationLink: navigationLink)
        case let navigationStack as JudoDocument.NavigationStackNode:
            NavigationStackView(navigationStack: navigationStack)
        case let picker as JudoDocument.PickerNode:
            PickerView(picker: picker)
        case let rectangle as JudoDocument.RectangleNode:
            RectangleView(rectangle: rectangle)
        case let roundedRectangle as JudoDocument.RoundedRectangleNode:
            RoundedRectangleView(roundedRectangle: roundedRectangle)
        case let secureField as JudoDocument.SecureFieldNode:
            SecureFieldView(secureField: secureField)
        case let section as JudoDocument.SectionNode:
            SectionView(section: section)
        case let scrollView as JudoDocument.ScrollViewNode:
            ScrollViewView(scrollView: scrollView)
        case let slider as JudoDocument.SliderNode:
            SliderView(slider: slider)
        case let spacer as JudoDocument.SpacerNode:
            SpacerView(spacer: spacer)
        case let stepper as JudoDocument.StepperNode:
            StepperView(stepper: stepper)
        case let tabView as JudoDocument.TabViewNode:
            TabViewView(tabView: tabView)
        case let text as JudoDocument.TextNode:
            TextView(text: text)
        case let textField as JudoDocument.TextFieldNode:
            TextFieldView(textField: textField)
        case let toggle as JudoDocument.ToggleNode:
            ToggleView(toggle: toggle)
        case let videoPlayer as JudoDocument.VideoPlayerNode:
            VideoPlayerView(videoPlayer: videoPlayer)
        case let stack as JudoDocument.VStackNode:
            VStackView(stack: stack)
        case let stack as JudoDocument.ZStackNode:
            ZStackView(stack: stack)
        default:
            EmptyView()
        }
    }
}

private struct NodeViewModifier: SwiftUI.ViewModifier {
    var node: Node
    
    func body(content: Content) -> some SwiftUI.View {
        content
            .modifier(
                ViewModifierContainer(node: node)
            )
    }
}
