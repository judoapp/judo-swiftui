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
            case let node as ArtboardNode:
                try container.encode(node)
            case let node as ContainerNode:
                try container.encode(node)
            case let node as MainComponentNode:
                try container.encode(node)
            
            // Layers
            case let node as AsyncImageLayer:
                try container.encode(node)
            case let node as ButtonLayer:
                try container.encode(node)
            case let node as CapsuleLayer:
                try container.encode(node)
            case let node as CircleLayer:
                try container.encode(node)
            case let node as CollectionLayer:
                try container.encode(node)
            case let node as CombinedTextLayer:
                try container.encode(node)
            case let node as ComponentInstanceLayer:
                try container.encode(node)
            case let node as ConditionalLayer:
                try container.encode(node)
            case let node as DataSourceLayer:
                try container.encode(node)
            case let node as DividerLayer:
                try container.encode(node)
            case let node as EllipseLayer:
                try container.encode(node)
            case let node as FormLayer:
                try container.encode(node)
            case let node as HStackLayer:
                try container.encode(node)
            case let node as ImageLayer:
                try container.encode(node)
            case let node as NavigationLinkLayer:
                try container.encode(node)
            case let node as NavigationStackLayer:
                try container.encode(node)
            case let node as PickerLayer:
                try container.encode(node)
            case let node as RectangleLayer:
                try container.encode(node)
            case let node as RoundedRectangleLayer:
                try container.encode(node)
            case let node as SecureFieldLayer:
                try container.encode(node)
            case let node as SectionLayer:
                try container.encode(node)
            case let node as ScrollViewLayer:
                try container.encode(node)
            case let node as SliderLayer:
                try container.encode(node)
            case let node as SpacerLayer:
                try container.encode(node)
            case let node as StepperLayer:
                try container.encode(node)
            case let node as TabViewLayer:
                try container.encode(node)
            case let node as TextLayer:
                try container.encode(node)
            case let node as TextFieldLayer:
                try container.encode(node)
            case let node as ToggleLayer:
                try container.encode(node)
            case let node as VideoPlayerLayer:
                try container.encode(node)
            case let node as VStackLayer:
                try container.encode(node)
            case let node as ZStackLayer:
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
            case let node as MinimumScaleFactorModifier:
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
