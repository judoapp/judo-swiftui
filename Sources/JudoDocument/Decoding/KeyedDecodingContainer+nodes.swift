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

extension KeyedDecodingContainer {
    func decodeNodes(forKey key: K) throws -> [Node] {
        try decode([NodeWrapper].self, forKey: key).compactMap(\.node)
    }

    func decodeNode(for key: K) throws -> Node? {
        try decode(NodeWrapper.self, forKey: key).node
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
        // ..<18
        case "CollectionLayer":
            node = try CollectionNode(from: decoder)
        
        // Main Component
        case MainComponentNode.typeName:
            node = try MainComponentNode(from: decoder)
            
        // Layers
        case ButtonNode.typeName:
            node = try ButtonNode(from: decoder)
        case CapsuleNode.typeName:
            node = try CapsuleNode(from: decoder)
        case CircleNode.typeName:
            node = try CircleNode(from: decoder)
        case CollectionNode.typeName:
            node = try CollectionNode(from: decoder)
        case ComponentInstanceNode.typeName:
            node = try ComponentInstanceNode(from: decoder)
        case ConditionalNode.typeName:
            node = try ConditionalNode(from: decoder)
        case DataSourceNode.typeName:
            node = try DataSourceNode(from: decoder)
        case DividerNode.typeName:
            node = try DividerNode(from: decoder)
        case EllipseNode.typeName:
            node = try EllipseNode(from: decoder)
        case FormNode.typeName:
            node = try FormNode(from: decoder)
        case HStackNode.typeName:
            node = try HStackNode(from: decoder)
        case ImageNode.typeName:
            node = try ImageNode(from: decoder)
        case AsyncImageNode.typeName:
            node = try AsyncImageNode(from: decoder)
        case NavigationLinkNode.typeName:
            node = try NavigationLinkNode(from: decoder)
        case NavigationStackNode.typeName:
            node = try NavigationStackNode(from: decoder)
        case PickerNode.typeName:
            node = try PickerNode(from: decoder)
        case RectangleNode.typeName:
            node = try RectangleNode(from: decoder)
        case RoundedRectangleNode.typeName:
            node = try RoundedRectangleNode(from: decoder)
        case SecureFieldNode.typeName:
            node = try SecureFieldNode(from: decoder)
        case SectionNode.typeName:
            node = try SectionNode(from: decoder)
        case ScrollViewNode.typeName:
            node = try ScrollViewNode(from: decoder)
        case SliderNode.typeName:
            node = try SliderNode(from: decoder)
        case SpacerNode.typeName:
            node = try SpacerNode(from: decoder)
        case StepperNode.typeName:
            node = try StepperNode(from: decoder)
        case TabViewNode.typeName:
            node = try TabViewNode(from: decoder)
        case TextNode.typeName:
            node = try TextNode(from: decoder)
        case TextFieldNode.typeName:
            node = try TextFieldNode(from: decoder)
        case ToggleNode.typeName:
            node = try ToggleNode(from: decoder)
        case VideoPlayerNode.typeName:
            node = try VideoPlayerNode(from: decoder)
        case VStackNode.typeName:
            node = try VStackNode(from: decoder)
        case ZStackNode.typeName:
            node = try ZStackNode(from: decoder)

            
        // Container
        case ContainerNode.typeName:
            node = try ContainerNode(from: decoder)
            
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
        case BlendModeModifier.typeName:
            node = try BlendModeModifier(from: decoder)
        case BlurModifier.typeName:
            node = try BlurModifier(from: decoder)
        case BoldModifier.typeName:
            node = try BoldModifier(from: decoder)
        case BorderModifier.typeName:
            node = try BorderModifier(from: decoder)
        case ButtonStyleModifier.typeName:
            node = try ButtonStyleModifier(from: decoder)
        case ContainerRelativeFrameModifier.typeName:
            node = try ContainerRelativeFrameModifier(from: decoder)
        case ClippedModifier.typeName:
            node = try ClippedModifier(from: decoder)
        case ClipShapeModifier.typeName:
            node = try ClipShapeModifier(from: decoder)
        case FixedSizeModifier.typeName:
            node = try FixedSizeModifier(from: decoder)
        case FontModifier.typeName:
            node = try FontModifier(from: decoder)
        case FontWeightModifier.typeName:
            node = try FontWeightModifier(from: decoder)
        case ForegroundColorModifier.typeName:
            node = try ForegroundColorModifier(from: decoder)
        case FrameModifier.typeName:
            node = try FrameModifier(from: decoder)
        case FullScreenCoverModifier.typeName:
            node = try FullScreenCoverModifier(from: decoder)
        case IgnoresSafeAreaModifier.typeName:
            node = try IgnoresSafeAreaModifier(from: decoder)
        case IndexViewStyleModifier.typeName:
            node = try IndexViewStyleModifier(from: decoder)
        case InteractiveDismissDisabledModifier.typeName:
            node = try InteractiveDismissDisabledModifier(from: decoder)
        case ItalicModifier.typeName:
            node = try ItalicModifier(from: decoder)
        case KerningModifier.typeName:
            node = try KerningModifier(from: decoder)
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
        case OnAppearModifier.typeName:
            node = try OnAppearModifier(from: decoder)
        case OnDisappearModifier.typeName:
            node = try OnDisappearModifier(from: decoder)
        case OnTapGestureModifier.typeName:
            node = try OnTapGestureModifier(from: decoder)
        case OpacityModifier.typeName:
            node = try OpacityModifier(from: decoder)
        case OverlayModifier.typeName:
            node = try OverlayModifier(from: decoder)
        case PaddingModifier.typeName:
            node = try PaddingModifier(from: decoder)
        case PickerStyleModifier.typeName:
            node = try PickerStyleModifier(from: decoder)
        case PositionModifier.typeName:
            node = try PositionModifier(from: decoder)
        case PresentationBackgroundModifier.typeName:
            node = try PresentationBackgroundModifier(from: decoder)
        case PresentationBackgroundInteractionModifier.typeName:
            node = try PresentationBackgroundInteractionModifier(from: decoder)
        case PresentationContentInteractionModifier.typeName:
            node = try PresentationContentInteractionModifier(from: decoder)
        case PresentationCornerRadiusModifier.typeName:
            node = try PresentationCornerRadiusModifier(from: decoder)
        case PresentationDetentsModifier.typeName:
            node = try PresentationDetentsModifier(from: decoder)
        case PresentationDragIndicatorModifier.typeName:
            node = try PresentationDragIndicatorModifier(from: decoder)
        case RotationEffectModifier.typeName:
            node = try RotationEffectModifier(from: decoder)
        case ScaledToFillModifier.typeName:
            node = try ScaledToFillModifier(from: decoder)
        case ScaledToFitModifier.typeName:
            node = try ScaledToFitModifier(from: decoder)
        case ScrollTargetBehaviorModifier.typeName:
            node = try ScrollTargetBehaviorModifier(from: decoder)
        case ScrollTargetLayoutModifier.typeName:
            node = try ScrollTargetLayoutModifier(from: decoder)
        case ShadowModifier.typeName:
            node = try ShadowModifier(from: decoder)
        case SheetModifier.typeName:
            node = try SheetModifier(from: decoder)
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
        case TrackingModifier.typeName:
            node = try TrackingModifier(from: decoder)
        case UnderlineModifier.typeName:
            node = try UnderlineModifier(from: decoder)

        default:
            throw DecodingError.typeMismatch(
                Node.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown node type: \(typeName)",
                    underlyingError: nil
                )
            )
        }
    }
}
