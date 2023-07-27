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

@objc public class JudoObject: NSObject, Codable, Identifiable, NSCopying, ObservableObject, UndoableObject {
    public class var humanName: String {
        typeName
    }
    
    public class var typeName: String {
        String(describing: Self.self)
    }
    
    public private(set) var id: ID
    
    override public required init() {
        self.id = .create()
        super.init()
    }
    
    // MARK: Description
    
    @objc dynamic override public var description: String {
        type(of: self).humanName
    }

    override public var debugDescription: String {
        return "\(description) (\(id))"
    }
    
    /// An array of stringly typed key paths that affect the value of a node's description. Subclasses should override this value if their description is computed based on properties in addition to the node's name.
    public class var keyPathsAffectingDescription: Set<String> {
        []
    }
    
    // MARK: KVO

    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)

        switch key {
        case "description":
            keyPaths.formUnion(keyPathsAffectingDescription)
        default:
            break
        }
        
        return keyPaths
    }
    
    // MARK: NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        let object = Self()
        object.id = .create()
        return object
    }
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(JudoObject.ID.self, forKey: .id)
        super.init()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
    }
}

extension JudoObject {
    public typealias ID = String
}

fileprivate extension JudoObject.ID {
    static func create() -> Self {
        UUID().uuidString
    }
}
