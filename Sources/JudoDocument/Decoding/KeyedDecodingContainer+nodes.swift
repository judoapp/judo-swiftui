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
        case ArtboardNode.typeName:
            node = try ArtboardNode(from: decoder)
        case ContainerNode.typeName:
            node = try ContainerNode(from: decoder)
        case MainComponentNode.typeName:
            node = try MainComponentNode(from: decoder)
            
        // Layers
        case AsyncImageLayer.typeName:
            node = try AsyncImageLayer(from: decoder)
        case ButtonLayer.typeName:
            node = try ButtonLayer(from: decoder)
        case CapsuleLayer.typeName:
            node = try CapsuleLayer(from: decoder)
        case CircleLayer.typeName:
            node = try CircleLayer(from: decoder)
        case CollectionLayer.typeName, "CollectionLayer":
            node = try CollectionLayer(from: decoder)
        case CombinedTextLayer.typeName:
            node = try CombinedTextLayer(from: decoder)
        case ComponentInstanceLayer.typeName:
            node = try ComponentInstanceLayer(from: decoder)
        case ConditionalLayer.typeName:
            node = try ConditionalLayer(from: decoder)
        case DataSourceLayer.typeName:
            node = try DataSourceLayer(from: decoder)
        case DividerLayer.typeName:
            node = try DividerLayer(from: decoder)
        case EllipseLayer.typeName:
            node = try EllipseLayer(from: decoder)
        case FormLayer.typeName:
            node = try FormLayer(from: decoder)
        case HStackLayer.typeName:
            node = try HStackLayer(from: decoder)
        case ImageLayer.typeName:
            node = try ImageLayer(from: decoder)
        case NavigationLinkLayer.typeName:
            node = try NavigationLinkLayer(from: decoder)
        case NavigationStackLayer.typeName:
            node = try NavigationStackLayer(from: decoder)
        case PickerLayer.typeName:
            node = try PickerLayer(from: decoder)
        case RectangleLayer.typeName:
            node = try RectangleLayer(from: decoder)
        case RoundedRectangleLayer.typeName:
            node = try RoundedRectangleLayer(from: decoder)
        case SecureFieldLayer.typeName:
            node = try SecureFieldLayer(from: decoder)
        case SectionLayer.typeName:
            node = try SectionLayer(from: decoder)
        case ScrollViewLayer.typeName:
            node = try ScrollViewLayer(from: decoder)
        case SliderLayer.typeName:
            node = try SliderLayer(from: decoder)
        case SpacerLayer.typeName:
            node = try SpacerLayer(from: decoder)
        case StepperLayer.typeName:
            node = try StepperLayer(from: decoder)
        case TabViewLayer.typeName:
            node = try TabViewLayer(from: decoder)
        case TextLayer.typeName:
            node = try TextLayer(from: decoder)
        case TextFieldLayer.typeName:
            node = try TextFieldLayer(from: decoder)
        case ToggleLayer.typeName:
            node = try ToggleLayer(from: decoder)
        case VideoPlayerLayer.typeName:
            node = try VideoPlayerLayer(from: decoder)
        case VStackLayer.typeName:
            node = try VStackLayer(from: decoder)
        case ZStackLayer.typeName:
            node = try ZStackLayer(from: decoder)
            
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
        case MinimumScaleFactorModifier.typeName:
            node = try MinimumScaleFactorModifier(from: decoder)
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
