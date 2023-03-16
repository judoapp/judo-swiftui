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
import UniformTypeIdentifiers
import CryptoKit
import AVFoundation
import os.log

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct MediaValue: AssetValue {
    // These are the formats explicitly supported by Judo's entire stack (namely, the SDKs). In future when the Judo app gains the ability to transcode, then these will be removed and instead used as transcoding targets, and the app will allow for importing generally any multimedia formats/containers supported by AVFoundation.
    
    public static var supportedVideoTypes: [UTTypeReference] {
        // These are containers, which commonly can now contain h264 and h265 content, which we support.  We may do codec checking within the container within the import process if it proves needed for mobile SDK support.
        VideoType.allCases.map { UTTypeReference(importedAs: $0.rawValue) }
    }
    
    public static var supportedAudioTypes: [UTTypeReference] {
        AudioType.allCases.map { UTTypeReference(importedAs: $0.rawValue) }
    }
    
    public var hash: String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    private enum VideoType: String, CaseIterable {
        case quickTimeMovie = "com.apple.quicktime-movie"
        case mpeg4Movie = "public.mpeg-4"
    }

    private enum AudioType: String, CaseIterable {
        case mp3 = "public.mp3"
        case mpeg4Audio = "public.mpeg-4-audio"
    }
    
    public var fileExtension: String
    
    public var filename: String {
        "\(hash).\(fileExtension)"
    }
        
    public let data: Data
    public let avAsset: AVURLAsset
    
    private let loader: InMemoryResourceLoader
    
    public init(url: URL) throws {
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else {
            throw AssetImportError(reason: "Unable to read file")
        }
        
        // we cannot detect file type from contents, so we will do so from the URL.
        let fileExtension = url.pathExtension
        
        try self.init(data: data, fileExtension: fileExtension)
    }
    
    public init(data: Data, fileExtension: String) throws {
        if data.count > (15 * (1 << 20)) {
            throw AssetImportError(reason: "File too large (15 MiB limit)")
        }
        
        guard let typeReference = UTTypeReference.init(filenameExtension: fileExtension) else {
            throw AssetImportError(reason: "Invalid file extension '\(fileExtension)'")
        }
        
        guard let matchedType = UTTypeReference.init(judoMediaExtension: fileExtension) else {
            throw AssetImportError(reason: "Unsupported file extension '\(fileExtension)'")
        }

        let hash = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        let asset = AVFoundation.AVURLAsset(url: URL(string: "judo-data-target://\(hash)")!)
        self.fileExtension = fileExtension
        self.loader = InMemoryResourceLoader(data: data, utType: matchedType)

        asset.resourceLoader.setDelegate(self.loader, queue: .init(label: "MediaValue Resource Loader"))
        
        self.data = data
        
        // now determine if the media matches our format/codec requirements.
        if typeReference.conformsToAny(of: Self.supportedVideoTypes) != nil {
            let videoTracks = asset.tracks(withMediaType: .video)
            guard !videoTracks.isEmpty else {
                throw AssetImportError(reason: "Video file contained no video tracks")
            }

            let unsupportedVideoFormats = videoTracks.flatMap(\.formatDescriptionsCast).filter({ formatDescription in
                return !CMFormatDescription.MediaSubType.judoSupportedVideoCodecs.contains(formatDescription.mediaSubType)
            })
            
            guard unsupportedVideoFormats.isEmpty else {
                let codecsString = unsupportedVideoFormats.map(\.mediaSubType.description).joined(separator: ", ")
                throw AssetImportError(reason: "Video file contained unsupported video codec(s): \(codecsString)")
            }

            let audioTracks = asset.tracks(withMediaType: .audio)
            
            let unsupportedAudioFormats = audioTracks.flatMap(\.formatDescriptionsCast).filter({ formatDescription in
                return !CMFormatDescription.MediaSubType.judoSupportedAudioCodecs.contains(formatDescription.mediaSubType)
            })
            
            guard unsupportedAudioFormats.isEmpty else {
                let codecsString = unsupportedAudioFormats.map(\.mediaSubType.description).joined(separator: ", ")
                throw AssetImportError(reason: "Audio file contained unsupported audio codec(s): \(codecsString)")
            }
            
        } else if typeReference.conformsToAny(of: Self.supportedAudioTypes) != nil  {
            let audioTracks = asset.tracks(withMediaType: .audio)
            guard !audioTracks.isEmpty else {
                throw AssetImportError(reason: "Audio file contained no audio tracks")
            }
            
            let unsupportedFormats = audioTracks.flatMap(\.formatDescriptionsCast).filter({ formatDescription in
                return !CMFormatDescription.MediaSubType.judoSupportedAudioCodecs.contains(formatDescription.mediaSubType)
            })
            
            guard unsupportedFormats.isEmpty else {
                let codecsString = unsupportedFormats.map(\.mediaSubType.description).joined(separator: ", ")
                throw AssetImportError(reason: "Audio file contained unsupported audio track codec(s): \(codecsString)")
            }
        }

        self.avAsset = asset
    }
    
    public var utTypeReference: UTTypeReference {
        // Guaranteed to be valid, since the MediaType wouldn't have initialized if it was not.
        UTTypeReference(filenameExtension: self.fileExtension)!
    }
    
    public var containsVideo: Bool {
        utTypeReference.conformsToAny(of: Self.supportedVideoTypes) != nil
    }
    
    public var containsAudio: Bool {
        utTypeReference.conformsToAny(of: Self.supportedAudioTypes) != nil
    }
    
    /// Synchronously generate a thumbnail (aka 'poster') for this video content.
    public func generatePoster() -> ImageValue? {
        if self.utTypeReference.conformsToAny(of: Self.supportedVideoTypes) == nil {
            // can't generate posters for audio.
            assertionFailure("Can't generate a poster for audio.")
            return nil
        }
        
        let generator = AVAssetImageGenerator(asset: self.avAsset)
        generator.appliesPreferredTrackTransform = true
        let cgImage: CGImage
        do {
            cgImage = try generator.copyCGImage(at: CMTime(seconds: Double(self.avAsset.duration.seconds) / 3, preferredTimescale: 1), actualTime: nil)
        } catch {
            os_log("Unable to generate poster image from video AVAsset. %@", error.localizedDescription)
            return nil
        }


        #if canImport(AppKit)

        guard let jpeg = NSImage(cgImage: cgImage, size: .zero).jpegData() else {
            return nil
        }
        return try? ImageValue(data: jpeg)

        #elseif canImport(UIKit)

        guard let jpeg = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8) else { return nil }
        return try? ImageValue(data: jpeg)

        #endif
    }
}

#if canImport(AppKit)
extension NSImage {
    func jpegData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = self.size
        return imageRep.representation(using: .jpeg, properties: [:])
    }
}
#endif

private class AssetImportError: LocalizedError {
    init(reason: String) {
        self.reason = reason
    }
    
    var reason: String
    
    var errorDescription: String? {
        "Unable to import media"
    }
    
    var failureReason: String? {
        reason
    }
}

private class InMemoryResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    init(data: Data, utType: UTTypeReference) {
        self.data = data
        self.utType = utType
    }
    
    var data: Data
    var utType: UTTypeReference
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        if let contentInformationRequest = loadingRequest.contentInformationRequest {
            os_log("Satisfying content information request.", type: .debug)
            contentInformationRequest.contentLength = Int64(data.count)
            contentInformationRequest.isByteRangeAccessSupported = true
            contentInformationRequest.contentType = utType.identifier
        }
        
        if let dataRequest = loadingRequest.dataRequest {
            let end = min(data.count, Int(dataRequest.currentOffset) + dataRequest.requestedLength)
            let range: Range<Int> = Int(dataRequest.currentOffset)..<end
            let chunk: Data = data.subdata(in: range)
            os_log("Yielding media chunk between %@, ", type: .debug, range.description)
            dataRequest.respond(
                with: chunk
            )
            
            if end == data.count {
                os_log("Finished yielding media data", type: .debug)
                loadingRequest.finishLoading()
            }
        }
        
        loadingRequest.finishLoading()
        return true
    }
}

private extension UTTypeReference {
    convenience init?(judoMediaExtension: String) {
        guard let typeReference = UTTypeReference.init(filenameExtension: judoMediaExtension) else {
            os_log("Invalid file extension '%@'", type: .error, judoMediaExtension)
            return nil
        }
        
        if let matchingVideoType = typeReference.conformsToAny(of: MediaValue.supportedVideoTypes) {
            self.init(matchingVideoType.identifier)
        } else if let matchingAudioType = typeReference.conformsToAny(of: MediaValue.supportedAudioTypes) {
            self.init(matchingAudioType.identifier)
        } else {
            return nil
        }
    }
}

private extension UTTypeReference {
    func conformsToAny(of types: [UTTypeReference]) -> UTTypeReference? {
        types.first {
            self.identifier == $0.identifier
        }
    }
}

private extension AVAssetTrack {
    var formatDescriptionsCast: [CMFormatDescription] {
        // the objc-to-swift bindings can't properly cast-check this, and they didn't sugar the API with a wrapper, so providing our own.
        formatDescriptions as! [CMFormatDescription]
    }
}

private extension CMFormatDescription.MediaSubType {
    static var judoSupportedAudioCodecs: [CMFormatDescription.MediaSubType] {
        return [.mpegLayer3, .mpeg4AAC]
    }
    
    static var judoSupportedVideoCodecs: [CMFormatDescription.MediaSubType] {
        return [
            .h264,
            .hevc // h265
        ]
    }
}
