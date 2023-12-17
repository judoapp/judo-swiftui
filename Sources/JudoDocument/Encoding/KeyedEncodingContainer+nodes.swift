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

extension KeyedEncodingContainer {
    mutating func encodeNodes(_ nodes: [Node], forKey key: K) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        for node in nodes {
            switch node {
            case let node as AsyncImageNode:
                try container.encode(node)
            case let node as ButtonNode:
                try container.encode(node)
            case let node as CapsuleNode:
                try container.encode(node)
            case let node as CircleNode:
                try container.encode(node)
            case let node as CollectionNode:
                try container.encode(node)
            case let node as ComponentInstanceNode:
                try container.encode(node)
            case let node as ConditionalNode:
                try container.encode(node)
            case let node as DataSourceNode:
                try container.encode(node)
            case let node as DividerNode:
                try container.encode(node)
            case let node as EllipseNode:
                try container.encode(node)
            case let node as FormNode:
                try container.encode(node)
            case let node as HStackNode:
                try container.encode(node)
            case let node as ImageNode:
                try container.encode(node)
            case let node as MainComponentNode:
                try container.encode(node)
            case let node as NavigationLinkNode:
                try container.encode(node)
            case let node as NavigationStackNode:
                try container.encode(node)
            case let node as PickerNode:
                try container.encode(node)
            case let node as RectangleNode:
                try container.encode(node)
            case let node as RoundedRectangleNode:
                try container.encode(node)
            case let node as SecureFieldNode:
                try container.encode(node)
            case let node as SectionNode:
                try container.encode(node)
            case let node as ScrollViewNode:
                try container.encode(node)
            case let node as SliderNode:
                try container.encode(node)
            case let node as SpacerNode:
                try container.encode(node)
            case let node as StepperNode:
                try container.encode(node)
            case let node as TabViewNode:
                try container.encode(node)
            case let node as TextNode:
                try container.encode(node)
            case let node as TextFieldNode:
                try container.encode(node)
            case let node as ToggleNode:
                try container.encode(node)
            case let node as VideoPlayerNode:
                try container.encode(node)
            case let node as VStackNode:
                try container.encode(node)
            case let node as ZStackNode:
                try container.encode(node)
            case let node as ContainerNode:
                try container.encode(node)

            // Modifiers
            case let node as AccessibilityAddTraitsModifier:
                try container.encode(node)
            case let node as AccessibilityElementModifier:
                try container.encode(node)
            case let node as AccessibilityHiddenModifier:
                try container.encode(node)
            case let node as AccessibilityLabelModifier:
                try container.encode(node)
            case let node as AccessibilitySortPriorityModifier:
                try container.encode(node)
            case let node as AspectRatioModifier:
                try container.encode(node)
            case let node as AutocapitalizationModifier:
                try container.encode(node)
            case let node as AutocorrectionDisabledModifier:
                try container.encode(node)
            case let node as BackgroundModifier:
                try container.encode(node)
            case let node as BlendModeModifier:
                try container.encode(node)
            case let node as BlurModifier:
                try container.encode(node)
            case let node as BoldModifier:
                try container.encode(node)
            case let node as BorderModifier:
                try container.encode(node)
            case let node as ButtonStyleModifier:
                try container.encode(node)
            case let node as ContainerRelativeFrameModifier:
                try container.encode(node)
            case let node as ClippedModifier:
                try container.encode(node)
            case let node as ClipShapeModifier:
                try container.encode(node)
            case let node as FixedSizeModifier:
                try container.encode(node)
            case let node as FontModifier:
                try container.encode(node)
            case let node as FontWeightModifier:
                try container.encode(node)
            case let node as ForegroundColorModifier:
                try container.encode(node)
            case let node as FrameModifier:
                try container.encode(node)
            case let node as FullScreenCoverModifier:
                try container.encode(node)
            case let node as IgnoresSafeAreaModifier:
                try container.encode(node)
            case let node as IndexViewStyleModifier:
                try container.encode(node)
            case let node as InteractiveDismissDisabledModifier:
                try container.encode(node)
            case let node as ItalicModifier:
                try container.encode(node)
            case let node as KerningModifier:
                try container.encode(node)
            case let node as KeyboardTypeModifier:
                try container.encode(node)
            case let node as LabelsHiddenModifier:
                try container.encode(node)
            case let node as LayoutPriorityModifier:
                try container.encode(node)
            case let node as LineLimitModifier:
                try container.encode(node)
            case let node as MaskModifier:
                try container.encode(node)
            case let node as MultiLineTextAlignmentModifier:
                try container.encode(node)
            case let node as NavigationBarBackButtonHiddenModifier:
                try container.encode(node)
            case let node as NavigationBarHiddenModifier:
                try container.encode(node)
            case let node as NavigationBarTitleDisplayModeModifier:
                try container.encode(node)
            case let node as NavigationTitleModifier:
                try container.encode(node)
            case let node as OffsetModifier:
                try container.encode(node)
            case let node as OpacityModifier:
                try container.encode(node)
            case let node as OnAppearModifier:
                try container.encode(node)
            case let node as OnDisappearModifier:
                try container.encode(node)
            case let node as OnTapGestureModifier:
                try container.encode(node)
            case let node as OverlayModifier:
                try container.encode(node)
            case let node as PaddingModifier:
                try container.encode(node)
            case let node as PickerStyleModifier:
                try container.encode(node)
            case let node as PositionModifier:
                try container.encode(node)
            case let node as PresentationBackgroundModifier:
                try container.encode(node)
            case let node as PresentationBackgroundInteractionModifier:
                try container.encode(node)
            case let node as PresentationContentInteractionModifier:
                try container.encode(node)
            case let node as PresentationCornerRadiusModifier:
                try container.encode(node)
            case let node as PresentationDetentsModifier:
                try container.encode(node)
            case let node as PresentationDragIndicatorModifier:
                try container.encode(node)
            case let node as RotationEffectModifier:
                try container.encode(node)
            case let node as ScaledToFillModifier:
                try container.encode(node)
            case let node as ScaledToFitModifier:
                try container.encode(node)
            case let node as ScrollTargetBehaviorModifier:
                try container.encode(node)
            case let node as ScrollTargetLayoutModifier:
                try container.encode(node)
            case let node as ShadowModifier:
                try container.encode(node)
            case let node as SheetModifier:
                try container.encode(node)
            case let node as SubmitLabelModifier:
                try container.encode(node)
            case let node as TabItemModifier:
                try container.encode(node)
            case let node as TabViewStyleModifier:
                try container.encode(node)
            case let node as TextCaseModifier:
                try container.encode(node)
            case let node as TextContentTypeModifier:
                try container.encode(node)
            case let node as TextFieldStyleModifier:
                try container.encode(node)
            case let node as TintModifier:
                try container.encode(node)
            case let node as ToggleStyleModifier:
                try container.encode(node)
            case let node as ToolbarBackgroundColorModifier:
                try container.encode(node)
            case let node as ToolbarBackgroundVisibilityModifier:
                try container.encode(node)
            case let node as ToolbarColorSchemeModifier:
                try container.encode(node)
            case let node as ToolbarItemModifier:
                try container.encode(node)
            case let node as TrackingModifier:
                try container.encode(node)
            case let node as UnderlineModifier:
                try container.encode(node)
            default:
                throw EncodingError.invalidValue(
                    node,
                    EncodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid value: \(node)"
                    )
                )
            }
        }
    }
}
