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
        case let button as JudoDocument.ButtonLayer:
            ButtonView(button: button)
        case let capsule as JudoDocument.CapsuleLayer:
            CapsuleView(capsule: capsule)
        case let circle as JudoDocument.CircleLayer:
            CircleView(circle: circle)
        case let collection as CollectionLayer:
            CollectionView(collection: collection)
        case let combinedText as CombinedTextLayer:
            CombinedTextView(combinedText: combinedText)
        case let componentInstance as ComponentInstanceLayer:
            ComponentInstanceView(componentInstance: componentInstance)
        case let conditional as ConditionalLayer:
            ConditionalView(conditional: conditional)
        case let dataSource as DataSourceLayer:
            DataSourceView(dataSource: dataSource)
        case let divider as JudoDocument.DividerLayer:
            DividerView(divider: divider)
        case let ellipse as JudoDocument.EllipseLayer:
            EllipseView(ellipse: ellipse)
        case let form as JudoDocument.FormLayer:
            FormView(form: form)
        case let stack as JudoDocument.HStackLayer:
            HStackView(stack: stack)
        case let image as JudoDocument.ImageLayer:
            ImageView(image: image)
        case let image as JudoDocument.AsyncImageLayer:
            AsyncImageView(image: image)
        case let navigationLink as JudoDocument.NavigationLinkLayer:
            NavigationLinkView(navigationLink: navigationLink)
        case let navigationStack as JudoDocument.NavigationStackLayer:
            NavigationStackView(navigationStack: navigationStack)
        case let picker as JudoDocument.PickerLayer:
            PickerView(picker: picker)
        case let rectangle as JudoDocument.RectangleLayer:
            RectangleView(rectangle: rectangle)
        case let roundedRectangle as JudoDocument.RoundedRectangleLayer:
            RoundedRectangleView(roundedRectangle: roundedRectangle)
        case let secureField as JudoDocument.SecureFieldLayer:
            SecureFieldView(secureField: secureField)
        case let section as JudoDocument.SectionLayer:
            SectionView(section: section)
        case let scrollView as JudoDocument.ScrollViewLayer:
            ScrollViewView(scrollView: scrollView)
        case let slider as JudoDocument.SliderLayer:
            SliderView(slider: slider)
        case let spacer as JudoDocument.SpacerLayer:
            SpacerView(spacer: spacer)
        case let stepper as JudoDocument.StepperLayer:
            StepperView(stepper: stepper)
        case let tabView as JudoDocument.TabViewLayer:
            TabViewView(tabView: tabView)
        case let text as JudoDocument.TextLayer:
            TextView(text: text)
        case let textField as JudoDocument.TextFieldLayer:
            TextFieldView(textField: textField)
        case let toggle as JudoDocument.ToggleLayer:
            ToggleView(toggle: toggle)
        case let videoPlayer as JudoDocument.VideoPlayerLayer:
            VideoPlayerView(videoPlayer: videoPlayer)
        case let stack as JudoDocument.VStackLayer:
            VStackView(stack: stack)
        case let stack as JudoDocument.ZStackLayer:
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
