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
import CoreGraphics
import SwiftUI

@objc public final class DocumentData: NSObject, Codable, ObservableObject {

    @Published @objc public dynamic var nodes = [Node]()
    @Published public var colors = [DocumentColor]()
    @Published public var gradients = [DocumentGradient]()
    @Published public var fonts = [DocumentFont]()
    @Published public var localizations = DocumentLocalizations()

    override public init() {
        super.init()
    }

    public func update(from orig: DocumentData) {
        self.nodes = orig.nodes
        self.colors = orig.colors
        self.gradients = orig.gradients
        self.fonts = orig.fonts
        self.localizations = orig.localizations
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case nodes
        case colors
        case gradients
        case fonts
        case localizations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        nodes = try container.decodeNodes(forKey: .nodes)
        colors = try container.decode([DocumentColor].self, forKey: .colors)
        gradients = try container.decode([DocumentGradient].self, forKey: .gradients)
        fonts = try container.decode([DocumentFont].self, forKey: .fonts)

        if container.contains(.localizations) {
            localizations = try container.decode(DocumentLocalizations.self, forKey: .localizations)
        } else {
            localizations = coordinator.localizations
        }

        super.init()

        try coordinator.resolveRelationships(
            nodes: nodes,
            documentColors: colors,
            documentGradients: gradients
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(colors, forKey: .colors)
        try container.encode(gradients, forKey: .gradients)
        try container.encode(fonts, forKey: .fonts)
        try container.encode(localizations, forKey: .localizations)
    }
}
