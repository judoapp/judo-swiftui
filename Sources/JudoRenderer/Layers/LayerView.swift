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

struct LayerView: SwiftUI.View {
    private var layer: Layer
    
    init(layer: Layer) {
        self.layer = layer
    }
    
    var body: some SwiftUI.View {
        content
            .modifier(
                LayerViewModifier(layer: layer)
            )
    }
    
    @ViewBuilder private var content: some SwiftUI.View {
        switch layer {
        case let button as JudoModel.Button:
            ButtonView(button: button)
        case let capsule as JudoModel.Capsule:
            CapsuleView(capsule: capsule)
        case let circle as JudoModel.Circle:
            CircleView(circle: circle)
        case let collection as CollectionLayer:
          CollectionView(collection: collection)
        case let componentInstance as ComponentInstance:
            ComponentInstanceView(componentInstance: componentInstance)
        case let conditional as Conditional:
          ConditionalView(conditional: conditional)
        case let dataSource as DataSource:
          DataSourceView(dataSource: dataSource)
        case let divider as JudoModel.Divider:
            DividerView(divider: divider)
        case let ellipse as JudoModel.Ellipse:
            EllipseView(ellipse: ellipse)
        case let stack as JudoModel.HStack:
            HStackView(stack: stack)
        case let image as JudoModel.Image:
            ImageView(image: image)
        case let image as JudoModel.AsyncImage:
            AsyncImageView(image: image)
        case let navigationLink as JudoModel.NavigationLink:
            NavigationLinkView(navigationLink: navigationLink)
        case let navigationStack as JudoModel.NavigationStack:
            NavigationStackView(navigationStack: navigationStack)
        case let picker as JudoModel.Picker:
            PickerView(picker: picker)
        case let rectangle as JudoModel.Rectangle:
            RectangleView(rectangle: rectangle)
        case let roundedRectangle as JudoModel.RoundedRectangle:
            RoundedRectangleView(roundedRectangle: roundedRectangle)
        case let secureField as JudoModel.SecureField:
            SecureFieldView(secureField: secureField)
        case let scrollView as JudoModel.ScrollView:
            ScrollViewView(scrollView: scrollView)
        case let slider as JudoModel.Slider:
            SliderView(slider: slider)
        case let spacer as JudoModel.Spacer:
            SpacerView(spacer: spacer)
        case let stepper as JudoModel.Stepper:
            StepperView(stepper: stepper)
        case let tabView as JudoModel.TabView:
            TabViewView(tabView: tabView)
        case let text as JudoModel.Text:
            TextView(text: text)
        case let textField as JudoModel.TextField:
            TextFieldView(textField: textField)
        case let toggle as JudoModel.Toggle:
            ToggleView(toggle: toggle)
        case let stack as JudoModel.VStack:
            VStackView(stack: stack)
        case let stack as JudoModel.ZStack:
            ZStackView(stack: stack)
        default:
            SwiftUI.Text("Not supported")
            // have a screen, the app will be in a constant crash loop.
            // Commented out for now.
            // fatalError("Unknown layer type: \(String(describing: type(of: layer)))")
        }
    }
}

private struct LayerViewModifier: SwiftUI.ViewModifier {
    var layer: Layer
    
    func body(content: Content) -> some SwiftUI.View {
        if layer is Modifiable {
            content
                .modifier(
                    ViewModifierContainer(layer: layer)
                )
        } else {
            content
                .contentShape(
                    SwiftUI.Rectangle()
                )
        }
    }
}
