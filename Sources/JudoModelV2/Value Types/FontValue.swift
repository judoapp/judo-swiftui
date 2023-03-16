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
import CoreText
import CryptoKit

public struct FontValue: Hashable {
    public let fontFamily: FontFamily
    public let fontNames: [String]

    public let data: Data

    public var hash: String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    public let fileExtension: String

    public var filename: String {
        "\(hash).\(fileExtension)"
    }

    public init(data: Data, fileExtension: String) throws {
        self.data = data
        self.fileExtension = fileExtension

        let fontDescriptors = CTFontManagerCreateFontDescriptorsFromData(data as CFData) as! [CTFontDescriptor]

        self.fontFamily = CTFontDescriptorCopyAttribute(fontDescriptors[0], kCTFontFamilyNameAttribute) as! String
        self.fontNames = fontDescriptors.compactMap { fontDescriptor in
            CTFontDescriptorCopyAttribute(fontDescriptor, kCTFontNameAttribute) as? String
        }
    }
}

public extension FontValue {

    static func systemFonts(with fontNames: [FontName]) throws -> Set<FontValue> {
        try getSystemFonts(fontNames: Set(fontNames))
            .reduce(into: Set<FontValue>()) { result, fontFileURLToData in
                let fontFileURL = fontFileURLToData.key
                let fontData = fontFileURLToData.value
                try result.insert(FontValue(data: fontData, fileExtension: fontFileURL.pathExtension))
            }
    }

    /// Searches the system for the font names and returns a dictionary of the font file url to its data
    private static func getSystemFonts(fontNames: Set<FontName>) throws -> [URL: Data] {
        try fontNames.reduce(into: [:]) { (result, fontName) in
            let searchDescriptor = CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute: fontName] as CFDictionary)
            let fontCollection = CTFontCollectionCreateWithFontDescriptors([searchDescriptor] as CFArray, nil)

            for fontDescriptor in CTFontCollectionCreateMatchingFontDescriptors(fontCollection) as? [CTFontDescriptor] ?? [] {
                guard let fontFileURL = (CTFontDescriptorCopyAttribute(fontDescriptor, kCTFontURLAttribute) as? URL)?.standardizedFileURL else { continue }
                let data = try Data(contentsOf: fontFileURL)
                result[fontFileURL] = data
            }
        }
    }
}
