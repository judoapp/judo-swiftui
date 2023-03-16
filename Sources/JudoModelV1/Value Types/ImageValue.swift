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

#if canImport(Cocoa)
import Cocoa
public typealias AppleImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias AppleImage = UIImage
#endif
import CryptoKit
import os.log
import UniformTypeIdentifiers

public struct ImageValue: AssetValue {
    public static var readableTypeIdentifiers: [String] {
        ImageType.allCases.map(\.rawValue)
    }

    public static var empty: ImageValue {
        ImageValue(data: Data(), imageType: .png, image: AppleImage())
    }

    public enum ImageType: String, CaseIterable {
        case gif = "com.compuserve.gif"
        case jpg = "public.jpeg"
        case png = "public.png"
    }
    
    public var hash: String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public var fileExtension: String {
        switch imageType {
        case .gif:
            return "gif"
        case .jpg:
            return "jpg"
        case .png:
            return "png"
        }
    }
    
    public var filename: String {
        "\(hash).\(fileExtension)"
    }
    
    public var uti: String {
        imageType.rawValue
    }
    
    public let imageType: ImageType
    public let data: Data
    public let image: AppleImage
    
    public init(url: URL) throws {
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            throw AssetImportError(reason: "Unable to read file")
        }
        
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as NSData, nil),
              let imageSourceType = CGImageSourceGetType(imageSource),
              let imageType = ImageType(rawValue: imageSourceType as String) else {
            throw AssetImportError(reason: "Unable to read file")
        }
        
        guard let image = AppleImage(data: data) else {
            throw AssetImportError(reason: "Unable to read file")
        }
                
        self.init(data: data, imageType: imageType, image: image)
    }
    
    private init(data: Data, imageType: ImageType, image: AppleImage) {
        self.data = data
        self.imageType = imageType
        self.image = image

        #if os(macOS)
        // ensure the image has a 1x scale, rather than something determined from the display. This is particularly needed to make image tiling work correctly (to ensure the image has a consistent scaling factor so our own scaling will work correctly).
        image.size = NSSize(width: image.representations.first?.pixelsWide ?? 0, height: image.representations.first?.pixelsHigh ?? 0)
        #endif
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
}

private class AssetImportError: LocalizedError {
    init(reason: String) {
        self.reason = reason
    }

    var reason: String

    var errorDescription: String? {
        "Unable to import image"
    }

    var failureReason: String? {
        reason
    }
}

extension ImageValue {
    public static var posterPlaceholder: ImageValue {
        let url = Bundle(identifier: "app.judo.Model")!.url(forResource: "placeholder-poster", withExtension: "jpg")!
        return try! ImageValue(url: url)
    }
}
