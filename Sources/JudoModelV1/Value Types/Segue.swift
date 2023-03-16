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

public class Segue: Codable, Equatable, Identifiable, ObservableObject {
    public static func == (lhs: Segue, rhs: Segue) -> Bool {
        lhs === rhs
    }
    
    public enum Style: Codable, Hashable {
        case push
        case modal(presentationStyle: ModalPresentationStyle)
        
        private enum CodingKeys: String, CodingKey {
            case caseName = "__caseName"
            case presentationStyle
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let caseName = try container.decode(String.self, forKey: .caseName)
            switch caseName {
            case "push":
                self  = .push
            case "modal":
                let presentationStyle = try container.decode(ModalPresentationStyle.self, forKey: .presentationStyle)
                self = .modal(presentationStyle: presentationStyle)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .caseName,
                    in: container,
                    debugDescription: "Invalid value: \(caseName)"
                )
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .push:
                try container.encode("push", forKey: .caseName)
            case .modal(let presentationStyle):
                try container.encode("modal", forKey: .caseName)
                try container.encode(presentationStyle, forKey: .presentationStyle)
            }
        }
    }
    
    public let id: UUID
    
    @Published public var source: Node!
    @Published public var destination: Screen!
    @Published public var style: Style
    
    public init(source: Node, destination: Screen, style: Style) {
        self.id = UUID()
        self.source = source
        self.destination = destination
        self.style = style
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case id
        case sourceID
        case destinationID
        case style
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        style = try container.decode(Style.self, forKey: .style)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        coordinator.registerOneToOneRelationship(
            nodeID: try container.decode(Node.ID.self, forKey: .sourceID),
            to: self,
            keyPath: \.source,
            inverseKeyPath: \.segue
        )
        
        coordinator.registerManyToOneRelationship(
            nodeID: try container.decode(Node.ID.self, forKey: .destinationID),
            to: self,
            keyPath: \.destination,
            inverseKeyPath: \.inboundSegues
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(source.id, forKey: .sourceID)
        try container.encode(destination.id, forKey: .destinationID)
        try container.encode(style, forKey: .style)
    }
}
