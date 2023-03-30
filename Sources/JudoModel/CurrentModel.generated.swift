// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
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

// Current model target is JudoModelV2

// Update procedure:
// 1. Update `Sources/JudoModel/CurrentModel.stencil` file `modelName` with current value
// 2. Update .sourcery.yml with a source to current model target path (eg. `Sources/JudoModelV1`)
// 3. run `sourcery --config .sourcery.yml`

import Foundation
import JudoModelV2

public typealias Accessibility = JudoModelV2.Accessibility
public typealias AccessibilityAddTraitsModifier = JudoModelV2.AccessibilityAddTraitsModifier
public typealias AccessibilityChildBehavior = JudoModelV2.AccessibilityChildBehavior
public typealias AccessibilityElementModifier = JudoModelV2.AccessibilityElementModifier
public typealias AccessibilityHiddenModifier = JudoModelV2.AccessibilityHiddenModifier
public typealias AccessibilityLabelModifier = JudoModelV2.AccessibilityLabelModifier
public typealias AccessibilitySortPriorityModifier = JudoModelV2.AccessibilitySortPriorityModifier
public typealias AccessibilityTraits = JudoModelV2.AccessibilityTraits
public typealias ActionHandler = JudoModelV2.ActionHandler
public typealias Alignment = JudoModelV2.Alignment
public typealias ApplicableActions = JudoModelV2.ApplicableActions
public typealias AspectRatioModifier = JudoModelV2.AspectRatioModifier
public typealias Assets = JudoModelV2.Assets
public typealias AsyncImage = JudoModelV2.AsyncImage
public typealias Axes = JudoModelV2.Axes
public typealias BackButtonStyle = JudoModelV2.BackButtonStyle
public typealias BackgroundModifier = JudoModelV2.BackgroundModifier
public typealias BoldModifier = JudoModelV2.BoldModifier
public typealias Border = JudoModelV2.Border
public typealias Button = JudoModelV2.Button
public typealias ButtonAction = JudoModelV2.ButtonAction
public typealias ButtonRole = JudoModelV2.ButtonRole
public typealias ButtonStyle = JudoModelV2.ButtonStyle
public typealias ButtonStyleModifier = JudoModelV2.ButtonStyleModifier
public typealias Capsule = JudoModelV2.Capsule
public typealias Circle = JudoModelV2.Circle
public typealias CollectionLayer = JudoModelV2.CollectionLayer
public typealias ColorReference = JudoModelV2.ColorReference
public typealias ColorScheme = JudoModelV2.ColorScheme
public typealias ColorValue = JudoModelV2.ColorValue
public typealias ComponentInstance = JudoModelV2.ComponentInstance
public typealias Condition = JudoModelV2.Condition
public typealias Conditional = JudoModelV2.Conditional
public typealias Container = JudoModelV2.Container
public typealias ContentMode = JudoModelV2.ContentMode
public typealias ContentSizeCategory = JudoModelV2.ContentSizeCategory
public typealias CustomActionIdentifier = JudoModelV2.CustomActionIdentifier
public typealias DataContext = JudoModelV2.DataContext
public typealias DataSource = JudoModelV2.DataSource
public typealias DecodingCoordinator = JudoModelV2.DecodingCoordinator
public typealias Dependent = JudoModelV2.Dependent
public typealias DeviceSize = JudoModelV2.DeviceSize
public typealias DeviceType = JudoModelV2.DeviceType
public typealias Divider = JudoModelV2.Divider
public typealias DocumentColor = JudoModelV2.DocumentColor
public typealias DocumentData = JudoModelV2.DocumentData
public typealias DocumentFont = JudoModelV2.DocumentFont
public typealias DocumentGradient = JudoModelV2.DocumentGradient
public typealias DocumentLocalizations = JudoModelV2.DocumentLocalizations
public typealias Edge = JudoModelV2.Edge
public typealias Element = JudoModelV2.Element
public typealias Ellipse = JudoModelV2.Ellipse
public typealias Font = JudoModelV2.Font
public typealias FontDesign = JudoModelV2.FontDesign
public typealias FontModifier = JudoModelV2.FontModifier
public typealias FontTextStyle = JudoModelV2.FontTextStyle
public typealias FontValue = JudoModelV2.FontValue
public typealias FontWeight = JudoModelV2.FontWeight
public typealias ForegroundColorModifier = JudoModelV2.ForegroundColorModifier
public typealias Frame = JudoModelV2.Frame
public typealias FrameModifier = JudoModelV2.FrameModifier
public typealias GradientReference = JudoModelV2.GradientReference
public typealias GradientValue = JudoModelV2.GradientValue
public typealias HStack = JudoModelV2.HStack
public typealias HashableURLRequest = JudoModelV2.HashableURLRequest
public typealias HorizontalAlignment = JudoModelV2.HorizontalAlignment
public typealias Image = JudoModelV2.Image
public typealias ImageReference = JudoModelV2.ImageReference
public typealias ImageValue = JudoModelV2.ImageValue
public typealias IndexViewStyle = JudoModelV2.IndexViewStyle
public typealias IndexViewStyleModifier = JudoModelV2.IndexViewStyleModifier
public typealias ItalicModifier = JudoModelV2.ItalicModifier
public typealias JSON = JudoModelV2.JSON
public typealias JudoModifier = JudoModelV2.JudoModifier
public typealias Layer = JudoModelV2.Layer
public typealias LayoutPriorityModifier = JudoModelV2.LayoutPriorityModifier
public typealias LineLimitModifier = JudoModelV2.LineLimitModifier
public typealias MainComponent = JudoModelV2.MainComponent
public typealias MaskModifier = JudoModelV2.MaskModifier
public typealias Meta = JudoModelV2.Meta
public typealias Metadata = JudoModelV2.Metadata
public typealias ModalPresentationStyle = JudoModelV2.ModalPresentationStyle
public typealias MultiLineTextAlignmentModifier = JudoModelV2.MultiLineTextAlignmentModifier
public typealias NamedIcon = JudoModelV2.NamedIcon
public typealias NavigationBarBackButtonHiddenModifier = JudoModelV2.NavigationBarBackButtonHiddenModifier
public typealias NavigationBarHiddenModifier = JudoModelV2.NavigationBarHiddenModifier
public typealias NavigationBarTitleDisplayModeModifier = JudoModelV2.NavigationBarTitleDisplayModeModifier
public typealias NavigationLink = JudoModelV2.NavigationLink
public typealias NavigationStack = JudoModelV2.NavigationStack
public typealias NavigationTitleModifier = JudoModelV2.NavigationTitleModifier
public typealias Node = JudoModelV2.Node
public typealias OffsetModifier = JudoModelV2.OffsetModifier
public typealias OpacityModifier = JudoModelV2.OpacityModifier
public typealias OverlayModifier = JudoModelV2.OverlayModifier
public typealias Padding = JudoModelV2.Padding
public typealias PaddingModifier = JudoModelV2.PaddingModifier
public typealias PreviewLanguage = JudoModelV2.PreviewLanguage
public typealias Property = JudoModelV2.Property
public typealias RasterizationStyle = JudoModelV2.RasterizationStyle
public typealias Rectangle = JudoModelV2.Rectangle
public typealias ResizingMode = JudoModelV2.ResizingMode
public typealias RoundedCornerStyle = JudoModelV2.RoundedCornerStyle
public typealias RoundedRectangle = JudoModelV2.RoundedRectangle
public typealias ScaledToFillModifier = JudoModelV2.ScaledToFillModifier
public typealias ScaledToFitModifier = JudoModelV2.ScaledToFitModifier
public typealias ScrollView = JudoModelV2.ScrollView
public typealias Shadow = JudoModelV2.Shadow
public typealias ShadowModifier = JudoModelV2.ShadowModifier
public typealias Shape = JudoModelV2.Shape
public typealias ShapeStyle = JudoModelV2.ShapeStyle
public typealias SortDescriptor = JudoModelV2.SortDescriptor
public typealias Spacer = JudoModelV2.Spacer
public typealias StatusBarStyle = JudoModelV2.StatusBarStyle
public typealias StringExpressionError = JudoModelV2.StringExpressionError
public typealias SymbolRenderingMode = JudoModelV2.SymbolRenderingMode
public typealias TabItemModifier = JudoModelV2.TabItemModifier
public typealias TabView = JudoModelV2.TabView
public typealias TabViewStyle = JudoModelV2.TabViewStyle
public typealias TabViewStyleModifier = JudoModelV2.TabViewStyleModifier
public typealias TemplateRenderingMode = JudoModelV2.TemplateRenderingMode
public typealias Text = JudoModelV2.Text
public typealias TextAlignment = JudoModelV2.TextAlignment
public typealias TextCase = JudoModelV2.TextCase
public typealias TextCaseModifier = JudoModelV2.TextCaseModifier
public typealias TextValue = JudoModelV2.TextValue
public typealias TintModifier = JudoModelV2.TintModifier
public typealias TitleDisplayMode = JudoModelV2.TitleDisplayMode
public typealias ToolbarBackgroundColorModifier = JudoModelV2.ToolbarBackgroundColorModifier
public typealias ToolbarBackgroundVisibilityModifier = JudoModelV2.ToolbarBackgroundVisibilityModifier
public typealias ToolbarColorSchemeModifier = JudoModelV2.ToolbarColorSchemeModifier
public typealias ToolbarItemModifier = JudoModelV2.ToolbarItemModifier
public typealias ToolbarItemPlacement = JudoModelV2.ToolbarItemPlacement
public typealias ToolbarPlacement = JudoModelV2.ToolbarPlacement
public typealias Traits = JudoModelV2.Traits
public typealias UserData = JudoModelV2.UserData
public typealias VStack = JudoModelV2.VStack
public typealias VerticalAlignment = JudoModelV2.VerticalAlignment
public typealias Visibility = JudoModelV2.Visibility
public typealias ZStack = JudoModelV2.ZStack

public typealias FontFamily = JudoModelV2.FontFamily
public typealias FontName = JudoModelV2.FontName
public typealias UserInfo = JudoModelV2.UserInfo

public typealias AssetProvider = JudoModelV2.AssetProvider
public typealias Dependable = JudoModelV2.Dependable
public typealias Modifiable = JudoModelV2.Modifiable
public typealias UndoableObject = JudoModelV2.UndoableObject

