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

import Foundation
import OSLog

extension KeyedDecodingContainer {
    public func decodeNodes(forKey key: K) throws -> [Node] {
        try decode([NodeWrapper].self, forKey: key).compactMap(\.node)
    }
}

private struct NodeWrapper: Decodable {
    let node: Node?
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .typeName)
        
        switch typeName {
        
        // Main Component
        case MainComponent.typeName:
            node = try MainComponent(from: decoder)
            
        // Layers
        case Button.typeName:
            node = try Button(from: decoder)
        case Capsule.typeName:
            node = try Capsule(from: decoder)
        case Circle.typeName:
            node = try Circle(from: decoder)
        case CollectionLayer.typeName:
            node = try CollectionLayer(from: decoder)
        case ComponentInstance.typeName:
            node = try ComponentInstance(from: decoder)
        case Conditional.typeName:
            node = try Conditional(from: decoder)
        case DataSource.typeName:
            node = try DataSource(from: decoder)
        case Divider.typeName:
            node = try Divider(from: decoder)
        case Ellipse.typeName:
            node = try Ellipse(from: decoder)
        case HStack.typeName:
            node = try HStack(from: decoder)
        case Image.typeName:
            node = try Image(from: decoder)
        case AsyncImage.typeName:
            node = try AsyncImage(from: decoder)
        case NavigationLink.typeName:
            node = try NavigationLink(from: decoder)
        case NavigationStack.typeName:
            node = try NavigationStack(from: decoder)
        case Picker.typeName:
            node = try Picker(from: decoder)
        case Rectangle.typeName:
            node = try Rectangle(from: decoder)
        case RoundedRectangle.typeName:
            node = try RoundedRectangle(from: decoder)
        case SecureField.typeName:
            node = try SecureField(from: decoder)
        case ScrollView.typeName:
            node = try ScrollView(from: decoder)
        case Slider.typeName:
            node = try Slider(from: decoder)
        case Spacer.typeName:
            node = try Spacer(from: decoder)
        case Stepper.typeName:
            node = try Stepper(from: decoder)
        case TabView.typeName:
            node = try TabView(from: decoder)
        case Text.typeName:
            node = try Text(from: decoder)
        case TextField.typeName:
            node = try TextField(from: decoder)
        case Toggle.typeName:
            node = try Toggle(from: decoder)
        case VStack.typeName:
            node = try VStack(from: decoder)
        case ZStack.typeName:
            node = try ZStack(from: decoder)

            
        // Container
        case Container.typeName:
            node = try Container(from: decoder)
            
        // Modifiers
        case AccessibilityAddTraitsModifier.typeName:
            node = try AccessibilityAddTraitsModifier(from: decoder)
        case AccessibilityElementModifier.typeName:
            node = try AccessibilityElementModifier(from: decoder)
        case AccessibilityHiddenModifier.typeName:
            node = try AccessibilityHiddenModifier(from: decoder)
        case AccessibilityLabelModifier.typeName:
            node = try AccessibilityLabelModifier(from: decoder)
        case AccessibilitySortPriorityModifier.typeName:
            node = try AccessibilitySortPriorityModifier(from: decoder)
        case AspectRatioModifier.typeName:
            node = try AspectRatioModifier(from: decoder)
        case AutocapitalizationModifier.typeName:
            node = try AutocapitalizationModifier(from: decoder)
        case AutocorrectionDisabledModifier.typeName:
            node = try AutocorrectionDisabledModifier(from: decoder)
        case BackgroundModifier.typeName:
            node = try BackgroundModifier(from: decoder)
        case BoldModifier.typeName:
            node = try BoldModifier(from: decoder)
        case ButtonStyleModifier.typeName:
            node = try ButtonStyleModifier(from: decoder)
        case FontModifier.typeName:
            node = try FontModifier(from: decoder)
        case ForegroundColorModifier.typeName:
            node = try ForegroundColorModifier(from: decoder)
        case FrameModifier.typeName:
            node = try FrameModifier(from: decoder)
        case IgnoresSafeAreaModifier.typeName:
            node = try IgnoresSafeAreaModifier(from: decoder)
        case IndexViewStyleModifier.typeName:
            node = try IndexViewStyleModifier(from: decoder)
        case ItalicModifier.typeName:
            node = try ItalicModifier(from: decoder)
        case KeyboardTypeModifier.typeName:
            node = try KeyboardTypeModifier(from: decoder)
        case LabelsHiddenModifier.typeName:
            node = try LabelsHiddenModifier(from: decoder)
        case LayoutPriorityModifier.typeName:
            node = try LayoutPriorityModifier(from: decoder)
        case LineLimitModifier.typeName:
            node = try LineLimitModifier(from: decoder)
        case MaskModifier.typeName:
            node = try MaskModifier(from: decoder)
        case MultiLineTextAlignmentModifier.typeName:
            node = try MultiLineTextAlignmentModifier(from: decoder)
        case NavigationBarBackButtonHiddenModifier.typeName:
            node = try NavigationBarBackButtonHiddenModifier(from: decoder)
        case NavigationBarHiddenModifier.typeName:
            node = try NavigationBarHiddenModifier(from: decoder)
        case NavigationBarTitleDisplayModeModifier.typeName:
            node = try NavigationBarTitleDisplayModeModifier(from: decoder)
        case NavigationTitleModifier.typeName:
            node = try NavigationTitleModifier(from: decoder)
        case OffsetModifier.typeName:
            node = try OffsetModifier(from: decoder)
        case OpacityModifier.typeName:
            node = try OpacityModifier(from: decoder)
        case OverlayModifier.typeName:
            node = try OverlayModifier(from: decoder)
        case PaddingModifier.typeName:
            node = try PaddingModifier(from: decoder)
        case PickerStyleModifier.typeName:
            node = try PickerStyleModifier(from: decoder)
        case ScaledToFillModifier.typeName:
            node = try ScaledToFillModifier(from: decoder)
        case ScaledToFitModifier.typeName:
            node = try ScaledToFitModifier(from: decoder)
        case ShadowModifier.typeName:
            node = try ShadowModifier(from: decoder)
        case SubmitLabelModifier.typeName:
            node = try SubmitLabelModifier(from: decoder)
        case TabItemModifier.typeName:
            node = try TabItemModifier(from: decoder)
        case TabViewStyleModifier.typeName:
            node = try TabViewStyleModifier(from: decoder)
        case TextCaseModifier.typeName:
            node = try TextCaseModifier(from: decoder)
        case TextContentTypeModifier.typeName:
            node = try TextContentTypeModifier(from: decoder)
        case TextFieldStyleModifier.typeName:
            node = try TextFieldStyleModifier(from: decoder)
        case TintModifier.typeName:
            node = try TintModifier(from: decoder)
        case ToggleStyleModifier.typeName:
            node = try ToggleStyleModifier(from: decoder)
        case ToolbarBackgroundColorModifier.typeName:
            node = try ToolbarBackgroundColorModifier(from: decoder)
        case ToolbarBackgroundVisibilityModifier.typeName:
            node = try ToolbarBackgroundVisibilityModifier(from: decoder)
        case ToolbarColorSchemeModifier.typeName:
            node = try ToolbarColorSchemeModifier(from: decoder)
        case ToolbarItemModifier.typeName:
            node = try ToolbarItemModifier(from: decoder)
            
        default:
            node = nil
            os_log("Unknown %@ found when decoding.", type: .debug, typeName)
        }
    }
}
