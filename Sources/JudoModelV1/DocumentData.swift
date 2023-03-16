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
    public enum Appearance: String, Codable {
        case light
        case dark
        case auto
    }

    @Published @objc public dynamic var screens = [Screen]()
    @Published public var initialScreen: Screen?
    @Published public var segues = [Segue]()
    @Published public var colors = [DocumentColor]()
    @Published public var gradients = [DocumentGradient]()
    @Published public var fonts = [DocumentFont]()
    @Published public var appearance = Appearance.auto
    @Published public var urlParameters = UserInfo()
    @Published public var userInfo = UserInfo()
    @Published public var authorizers = [Authorizer]()
    @Published public var localizations = DocumentLocalizations()

    override public init() {
        super.init()
    }

    public func update(from orig: DocumentData) {
        self.screens = orig.screens
        self.initialScreen = orig.initialScreen
        self.segues = orig.segues
        self.colors = orig.colors
        self.gradients = orig.gradients
        self.fonts = orig.fonts
        self.appearance = orig.appearance
        self.urlParameters = orig.urlParameters
        self.userInfo = orig.userInfo
        self.authorizers = orig.authorizers
        self.localizations = orig.localizations
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case nodes
        case screenIDs
        case initialScreenID
        case segues
        case colors
        case gradients
        case fonts
        case appearance
        case urlParameters
        case userInfo
        case authorizers
        case localizations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        segues = try container.decode([Segue].self, forKey: .segues)
        colors = try container.decode([DocumentColor].self, forKey: .colors)
        gradients = try container.decode([DocumentGradient].self, forKey: .gradients)
        fonts = try container.decode([DocumentFont].self, forKey: .fonts)
        appearance = try container.decode(Appearance.self, forKey: .appearance)


        if coordinator.documentVersion >= 7 {
            urlParameters = try container.decode(UserInfo.self, forKey: .urlParameters)
        }

        userInfo = try container.decode(UserInfo.self, forKey: .userInfo)

        if coordinator.documentVersion >= 8 {
            authorizers = try container.decode([Authorizer].self, forKey: .authorizers)
        }

        if container.contains(.localizations) {
            localizations = try container.decode(DocumentLocalizations.self, forKey: .localizations)
        } else {
            localizations = coordinator.localizations
        }

        super.init()

        coordinator.registerOneToManyRelationship(
            nodeIDs: try container.decode([Node.ID].self, forKey: .screenIDs),
            to: self,
            keyPath: \.screens
        )

        if container.contains(.initialScreenID) {
            coordinator.registerOneToOneRelationship(
                nodeID: try container.decode(Node.ID.self, forKey: .initialScreenID),
                to: self,
                keyPath: \.initialScreen
            )
        }

        let nodes = try container.decodeNodes(forKey: .nodes)
        try coordinator.resolveRelationships(nodes: nodes, documentColors: colors, documentGradients: gradients)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screens.map(\.id), forKey: .screenIDs)
        try container.encodeIfPresent(initialScreen?.id, forKey: .initialScreenID)
        try container.encode(screens.flatten(), forKey: .nodes)
        try container.encode(segues, forKey: .segues)
        try container.encode(colors, forKey: .colors)
        try container.encode(gradients, forKey: .gradients)
        try container.encode(fonts, forKey: .fonts)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(urlParameters, forKey: .urlParameters)
        try container.encode(userInfo, forKey: .userInfo)
        try container.encode(authorizers, forKey: .authorizers)
        try container.encode(localizations, forKey: .localizations)
    }
}
