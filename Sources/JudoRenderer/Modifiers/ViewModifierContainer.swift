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

struct ViewModifierContainer: SwiftUI.ViewModifier {
    @ObservedObject var layer: Layer
    
    func body(content: Content) -> some SwiftUI.View {
        switch view.count {
        case 1:
            content.modifier(view[0])
        case 2:
            content.modifier(view[0]).modifier(view[1])
        case 3:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2])
        case 4:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3])
        case 5:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4])
        case 6:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5])
        case 7:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6])
        case 8:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
        case 9:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8])
        case 10:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9])
        case 11:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10])
        case 12:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11])
        case 13:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12])
        case 14:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13])
        case 15:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14])
        case 16:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
        case 17:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16])
        case 18:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17])
        case 19:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18])
        case 20:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19])
        case 21:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19]).modifier(view[20])
        case 22:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19]).modifier(view[20]).modifier(view[21])
        case 23:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19]).modifier(view[20]).modifier(view[21]).modifier(view[22])
        case 24:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19]).modifier(view[20]).modifier(view[21]).modifier(view[22]).modifier(view[23])
        case 25:
            content.modifier(view[0]).modifier(view[1]).modifier(view[2]).modifier(view[3]).modifier(view[4]).modifier(view[5]).modifier(view[6]).modifier(view[7])
                .modifier(view[8]).modifier(view[9]).modifier(view[10]).modifier(view[11]).modifier(view[12]).modifier(view[13]).modifier(view[14]).modifier(view[15])
                .modifier(view[16]).modifier(view[17]).modifier(view[18]).modifier(view[19]).modifier(view[20]).modifier(view[21]).modifier(view[22]).modifier(view[23])
                .modifier(view[24])
        default:
            content
        }
    }
    
    private var view: [JudoViewModifier] {
        layer.modifiers.map {
            JudoViewModifier(layer: layer, modifier: $0)
        }
    }
}

private struct JudoViewModifier: SwiftUI.ViewModifier {
    var layer: Layer
    var modifier: JudoModifier

    func body(content: Content) -> some SwiftUI.View {
        switch modifier {
        case let modifier as AccessibilityAddTraitsModifier:
            content.modifier(AccessibilityAddTraitsViewModifier(modifier: modifier))

        case let modifier as AccessibilityElementModifier:
            content.modifier(AccessibilityElementViewModifier(modifier: modifier))

        case let modifier as AccessibilityHiddenModifier:
            content.modifier(AccessibilityHiddenViewModifier(modifier: modifier))

        case let modifier as AccessibilityLabelModifier:
            content.modifier(AccessibilityLabelViewModifier(modifier: modifier))

        case let modifier as AccessibilitySortPriorityModifier:
            content.modifier(AccessibilitySortPriorityViewModifier(modifier: modifier))

        case let modifier as JudoModel.AspectRatioModifier:
            content.modifier(AspectRatioViewModifier(modifier: modifier))

        case let modifier as AutocapitalizationModifier:
            content.modifier(AutocapitalizationViewModifier(modifier: modifier))

        case let modifier as AutocorrectionDisabledModifier:
            content.modifier(AutocorrectionDisabledViewModifier(modifier: modifier))

        case let modifier as BackgroundModifier:
            content.modifier(BackgroundViewModifier(modifier: modifier))

        case let modifier as BlendModeModifier:
            content.modifier(BlendModeViewModifier(modifier: modifier))

        case let modifier as BoldModifier:
            content.modifier(BoldViewModifier(modifier: modifier))

        case let modifier as ButtonStyleModifier:
            content.modifier(ButtonStyleViewModifier(modifier: modifier))

        case let modifier as ClippedModifier:
            content.modifier(ClippedViewModifier(modifier: modifier))

        case let modifier as ClipShapeModifier:
            content.modifier(ClipShapeViewModifier(modifier: modifier))
            
        case let modifier as FixedSizeModifier:
            content.modifier(FixedSizeViewModifier(modifier: modifier))

        case let modifier as FontModifier:
            content.modifier(FontViewModifier(modifier: modifier))

        case let modifier as ForegroundColorModifier:
            content.modifier(ForegroundColorViewModifier(modifier: modifier))

        case let modifier as FrameModifier:
            content.modifier(FrameViewModifier(modifier: modifier))

        case let modifier as IgnoresSafeAreaModifier:
            content.modifier(IgnoresSafeAreaViewModifier(modifier: modifier))
            
        case let modifier as IndexViewStyleModifier:
            content.modifier(IndexViewStyleViewModifier(modifier: modifier))

        case let modifier as ItalicModifier:
            content.modifier(ItalicViewModifier(modifier: modifier))

        case let modifier as KeyboardTypeModifier:
            content.modifier(KeyboardTypeViewModifier(modifier: modifier))

        case let modifier as LabelsHiddenModifier:
            content.modifier(LabelsHiddenViewModifier(modifier: modifier))

        case let modifier as LayoutPriorityModifier:
            content.modifier(LayoutPriorityViewModifier(modifier: modifier))

        case let modifier as LineLimitModifier:
            content.modifier(LineLimitViewModifier(modifier: modifier))

        case let modifier as MaskModifier:
            content.modifier(MaskViewModifier(modifier: modifier))

        case let modifier as MultiLineTextAlignmentModifier:
            content.modifier(MultilineTextAlignmentViewModifier(modifier: modifier))

        case let modifier as NavigationBarBackButtonHiddenModifier:
            content.modifier(NavigationBarBackButtonHiddenViewModifier(modifier: modifier))

        case let modifier as NavigationBarHiddenModifier:
            content.modifier(NavigationBarHiddenViewModifier(modifier: modifier))

        case let modifier as NavigationBarTitleDisplayModeModifier:
            content.modifier(NavigationBarTitleDisplayModeViewModifier(modifier: modifier))

        case let modifier as NavigationTitleModifier:
            content.modifier(NavigationTitleViewModifier(modifier: modifier))

        case let modifier as OffsetModifier:
            content.modifier(OffsetViewModifier(modifier: modifier))

        case let modifier as OpacityModifier:
            content.modifier(OpacityViewModifier(modifier: modifier))

        case let modifier as OverlayModifier:
            content.modifier(OverlayViewModifier(modifier: modifier))

        case let modifier as PaddingModifier:
            content.modifier(PaddingViewModifier(modifier: modifier))

        case let modifier as PickerStyleModifier:
            content.modifier(PickerStyleViewModifier(modifier: modifier))

        case let modifier as PositionModifier:
            content.modifier(PositionViewModifier(modifier: modifier))

        case let modifier as RotationEffectModifier:
            content.modifier(RotationEffectViewModifier(modifier: modifier))

        case let modifier as ScaledToFillModifier:
            content.modifier(ScaledToFillViewModifier(modifier: modifier))

        case let modifier as ScaledToFitModifier:
            content.modifier(ScaledToFitViewModifier(modifier: modifier))

        case let modifier as ShadowModifier:
            content.modifier(ShadowViewModifier(modifier: modifier))

        case let modifier as SubmitLabelModifier:
            content.modifier(SubmitLabelViewModifier(modifier: modifier))

        case let modifier as TabItemModifier:
            content.modifier(TabItemViewModifier(modifier: modifier))

        case let modifier as TabViewStyleModifier:
            content.modifier(TabViewStyleViewModifier(modifier: modifier))

        case let modifier as TextCaseModifier:
            content.modifier(TextCaseViewModifier(modifier: modifier))

        case let modifier as TextContentTypeModifier:
            content.modifier(TextContentTypeViewModifier(modifier: modifier))

        case let modifier as TextFieldStyleModifier:
            content.modifier(TextFieldStyleViewModifier(modifier: modifier))

        case let modifier as TintModifier:
            content.modifier(TintViewModifier(modifier: modifier))

        case let modifier as ToggleStyleModifier:
            content.modifier(ToggleStyleViewModifier(modifier: modifier))

        case let modifier as ToolbarBackgroundColorModifier:
            content.modifier(ToolbarBackgroundColorViewModifier(modifier: modifier))

        case let modifier as ToolbarBackgroundVisibilityModifier:
            content.modifier(ToolbarBackgroundVisibilityViewModifier(modifier: modifier))

        case let modifier as ToolbarColorSchemeModifier:
            content.modifier(ToolbarColorSchemeViewModifier(modifier: modifier))

        case let modifier as ToolbarItemModifier:
            content.modifier(ToolbarItemViewModifier(modifier: modifier))
            
        default:
            // assertionFailure("Unable to find view modifier for \(modifier)")
            content
        }
    }
}
