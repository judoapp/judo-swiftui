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

/// The graphical image files for a named image asset used for instances of UIImage and NSImage.
public struct ImageSet: Codable {
    /// Properties for the image set.
    public struct Properties: Codable {
        /// The on-demand resource tags for the image set.
        public let onDemandResourceTags: [String] // on-demand-resource-tags

        /// Set to true to preserve the vector information for a PDF file.
        public let preservesVectorRepresentation: Bool // preserves-vector-representation

        public init(onDemandResourceTags: [String] = [], preservesVectorRepresentation: Bool = false) {
            self.onDemandResourceTags = onDemandResourceTags
            self.preservesVectorRepresentation = preservesVectorRepresentation
        }
    }

    /// The images in the image set.
    public struct Image: Codable {

        /// Image appearances. Appearances that apply to the image instance
        /// Single image may have none, one or more appearances assigned to it
        public struct Appearances: Codable, Hashable {

            public enum Appearance: String, CaseIterable, Codable {
                /// Luminosity mode
                case luminosity

                /// A high contrast image is used to increase the contrast between user interface elements.
                case contrast
            }

            public enum Value: String, CaseIterable, Codable {
                /// Light mode
                case light // Appearance: luminosity
                /// Dark mode
                case dark  // Appearance: luminosity
                /// A high contrast image is used to increase the contrast between user interface elements.
                case high  // Appearance: contrast
            }

            public static let `default` = Appearances.light
            public static let light = Appearances(appearance: .luminosity, value: .light)
            public static let dark = Appearances(appearance: .luminosity, value: .dark)
            public static let highContrast = Appearances(appearance: .contrast, value: .high)

            public let appearance: Appearance
            public let value: Value

            public init(appearance: Appearance, value: Value) {
                self.appearance = appearance
                self.value = value
            }
        }

        public enum ColorSpace: String, Codable {
            case srgb = "srgb"
            case displayP3 = "display-p3"
        }

        public enum CompressionType: String, Codable {
            case automatic = "automatic"
            case gpuPptimizedBest = "gpu-optimized-best"
            case gpuPptimizedSmallest = "gpu-optimized-smallest"
            case lossless = "lossless"
            case lossy = "lossy"
        }

        public enum DisplayGamut: String, Codable {
            case sRGB = "sRGB"
            case displayP3 = "display-P3"
        }

        /// The targeted display scale for the image
        public enum Scale: CaseIterable, Comparable, CustomStringConvertible, Codable, Identifiable {
            /// Targeted for unscaled displays.
            case one
            /// Targeted for Retina displays.
            case two
            ///  Targeted for Retina displays with higher density such as those on the iPhone 6 Plus.
            case three

            public var description: String {
                switch self {
                case .one:
                    return "1x"
                case .two:
                    return "2x"
                case .three:
                    return "3x"
                }
            }

            public var scale: CGFloat {
                switch self {
                case .one:
                    return 1
                case .two:
                    return 2
                case .three:
                    return 3
                }
            }

            public var id: Self {
                self
            }
        }

        public enum SizeClass: String, Codable {
            /// The image width is for the compact size class.
            case compact = "compact"
            /// The image width is for the regular size class.
            case regular = "regular"
        }

        public enum Idiom: String, Codable {
            case appLauncher
            case companionSettings
            case iOSMarketing = "ios-marketing"
            case iphone
            case ipad
            case mac
            case notificationCenter
            case quickLook
            case tv
            case universal // default
            case watch
            case watchMarketing = "watch-marketing"
        }

        public let colorSpace: ColorSpace? // color-space
        public let compressionType: CompressionType? // compression-type
        public let displayGamut: DisplayGamut? // display-gamut

        /// None: Provide appearances for any macOS version.
        /// Any, Dark: Provide additional appearances for dark mode. (Uses the Any appearances for light mode.)
        /// Any, Light, Dark: Provide additional appearances for both light and dark mode.
        public let appearances: Set<Appearances>?

        /// The HEIF, .png, .jpg, or .pdf file for the image.
        public let filename: String

        // graphics-feature-set

        public let idiom: Idiom?

        // language-direction
        // memory

        /// The targeted display scale for the image,
        ///
        /// When nil, then the image is for any display scale.
        public let scale: Scale?
        
        // screen-width
        public let widthClass: SizeClass? //width-class
        public let heightClass: SizeClass? //height-class
        // alignment-insets

        public init(appearances: Set<Appearances>?, colorSpace: ColorSpace? = nil, compressionType: CompressionType? = nil, displayGamut: DisplayGamut? = nil, filename: String, idiom: Idiom? = .universal, scale: Scale? = nil, widthClass: SizeClass? = nil, heightClass: SizeClass? = nil) {
            self.colorSpace = colorSpace
            self.compressionType = compressionType
            self.displayGamut = displayGamut
            self.filename = filename
            self.idiom = idiom
            self.scale = scale
            self.widthClass = widthClass
            self.heightClass = heightClass
            self.appearances = appearances
        }
    }

    /// Versioning information for the asset catalog.
    public let info: Info

    /// Properties for the image set.
    public let properties: Properties

    /// The images in the image set.
    public internal(set) var images: [ImageSet.Image]

    public init(info: Info = Info(), properties: Properties = Properties(), images: [ImageSet.Image]) {
        self.info = info
        self.properties = properties
        self.images = images
    }

    /// Find the best (closest) match for provided appearance and scale
    ///
    /// - Parameters:
    ///   - appearances: Image apppearance
    ///   - scale: Image scale
    ///   - strictAppearanceMatch: Match appearance without fallbacks
    ///   - searchOtherScale: Whether should keep searching for an image of a larger scale than specified above
    /// - Returns: Image instance if found
    public func image(for appearances: Image.Appearances?, scale: Image.Scale, strictAppearanceMatch: Bool, searchOtherScale: Bool) -> Image? {
        // Sort from most detailed to least detailed
        let sortedImages = images.filter({ $0.scale == scale }).sorted { lhs, rhs -> Bool in
            (lhs.appearances?.count ?? 0) > (rhs.appearances?.count ?? 0)
        }

        var match: ImageSet.Image?
        if strictAppearanceMatch {

            if let appearances = appearances {
                match = sortedImages.first { image in
                    if let imageAppearances = image.appearances,
                       !imageAppearances.intersection([appearances]).isEmpty
                    {
                        return true
                    }

                    return false
                }
            } else {
                // Any
                match = sortedImages.first { image in
                    if image.appearances == nil {
                        return true
                    }

                    return false
                }
            }
        } else {
            if let appearances = appearances {
                // Search for the first match from the most detailed to least detailed image
                match = sortedImages.first { image in

                    // Light, Dark
                    if let imageAppearances = image.appearances,
                       imageAppearances == [.light, .dark],
                       !imageAppearances.intersection([appearances]).isEmpty
                    {
                        return true
                    }

                    // Any, Dark
                    if let imageAppearances = image.appearances,
                       imageAppearances == [.dark],
                       !imageAppearances.intersection([appearances]).isEmpty
                    {
                        return true
                    }

                    // Any
                    if image.appearances == nil {
                        return true
                    }

                    return false
                }
            } else {

                // Search Any appearance
                match = sortedImages.reversed().first { image in

                    // Any
                    if image.appearances == nil {
                        return true
                    }

                    // Any, Dark
                    if image.appearances == [.dark] {
                        return true
                    }

                    // Light, Dark
                    if image.appearances == [.light, .dark] {
                        return true
                    }

                    return false
                }
            }
        }

        // check other scale
        if searchOtherScale, match == nil {
            for nextScale in Image.Scale.allCases where (nextScale != scale) && match == nil {
                match = image(for: appearances, scale: nextScale, strictAppearanceMatch: strictAppearanceMatch, searchOtherScale: false)
            }
        }

        return match
    }
}

