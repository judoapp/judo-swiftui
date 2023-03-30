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
import ZIPFoundation
import JudoModel

struct Loader {

    static func loadViewData(at path: String, skipCache: Bool) throws -> ViewData {

        if !skipCache, let cachedViewData = ViewCache.shared.value(for: path) {
             return cachedViewData
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let archive = ZIPFoundation.Archive(data: data, accessMode: .read)
        else {
            logger.error("Unable to open ZIP container")
            throw CocoaError(.fileReadCorruptFile)
        }

        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )

        // meta.json

        guard let metaFile = archive["meta.json"], metaFile.type == .file else {
            logger.error("Unable to read document due to ZIP decoding issue: meta.json is missing.")
            throw CocoaError(.fileReadUnknown)
        }

        logger.debug("Read archive from data at \(path)")

        let meta: JudoModel.Meta
        do {
            let metaData = try archive.extractEntire(entry: metaFile)
            meta = try decoder.decode(JudoModel.Meta.self, from: metaData)
        } catch {
            logger.error("Unable to read document metadata due to ZIP decoding issue: \(error.debugDescription)")
            throw CocoaError(.fileReadUnknown)
        }

        // assets
        let xcassets = archive.extractXCAssets()
        let fonts = try archive.extractFonts()
        let localizations = try archive.extractLocalizations()

        let decodingCoordinator = DecodingCoordinator(
            documentVersion: meta.version,
            compatibilityVersion: meta.compatibilityVersion,
            xcassets: xcassets,
            fonts: fonts,
            localizations: localizations
        )

        decoder.userInfo[.decodingCoordinator] = decodingCoordinator

        // document.json
        let documentData = DocumentData()
        guard let documentFile = archive["document.json"], documentFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        do {
            let extractedData = try archive.extractEntire(entry: documentFile)
            try documentData.update(from: decoder.decode(DocumentData.self, from: extractedData))
        } catch {
            logger.error("Unable to read document.json due to decoding issue: \(error.debugDescription)")
            throw CocoaError(.fileReadUnknown)
        }

        // fonts
        let importedFonts = ImportedFonts()
        do {
            importedFonts.fonts = try archive.extractFonts()
        } catch {
            logger.error("Unable to read fonts due to ZIP decoding issue: \(error.debugDescription)")
            throw CocoaError(.fileReadUnknown)
        }

        // TODO: rebuildStrings()

        let viewData = ViewData(
            meta: meta,
            documentData: documentData,
            assets: Assets(assets: xcassets),
            importedFonts: importedFonts,
            fonts: fonts,
            localizations: localizations
        )

        ViewCache.shared.add(
            key: path,
            value: viewData
        )

        return viewData
    }
}

private extension Error {
    /// Get a string giving a much more comprehensive explanation of the error, particularly when coming from certain platform types (Codable, in particular).
    var debugDescription: String {
        return "Error: \(self.localizedDescription), details: \((self as NSError).userInfo.debugDescription)"
    }
}
