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

public struct Condition: Codable, Hashable {
    public var keyPath: String
    public var predicate: Predicate
    public var value: Any?
    
    public init(keyPath: String, predicate: Predicate, value: Any? = nil) {
        self.keyPath = keyPath
        self.predicate = predicate
        self.value = value
    }

    // MARK: Equatable

    public static func == (lhs: Condition, rhs: Condition) -> Bool {
        guard lhs.keyPath == rhs.keyPath && lhs.predicate == rhs.predicate else {
            return false
        }
        
        switch (lhs.value, rhs.value) {
        case (let a as String, let b as String):
            return a == b
        case (let a as Double, let b as Double):
            return a == b
        case (let a as Bool, let b as Bool):
            return a == b
        case (let a as Date, let b as Date):
            return a == b
        case (.none, .none):
            return true
        default:
            return false
        }
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
        hasher.combine(predicate)
        
        switch value {
        case let value as String:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as Bool:
            hasher.combine(value)
        case let value as Date:
            hasher.combine(value)
        default:
            break
        }
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case keyPath
        case predicate
        case value
        
        // Legacy
        case dataKey
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta
        
        if meta.version >= 7 {
            keyPath = try container.decode(String.self, forKey: .keyPath)
        } else {
            let dataKey = try container.decode(String.self, forKey: .dataKey)
            keyPath = "data.\(dataKey)"
        }
        
        predicate = try container.decode(Predicate.self, forKey: .predicate)
        
        if let value = try? container.decode(String.self, forKey: .value) {
            self.value = value
        } else if let value = try? container.decode(Double.self, forKey: .value) {
            self.value = value
        } else if let value = try? container.decode(Bool.self, forKey: .value) {
            self.value = value
        } else if let value = try? container.decode(Date.self, forKey: .value) {
            self.value = value
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyPath, forKey: .keyPath)
        try container.encode(predicate, forKey: .predicate)
        
        switch value {
        case let value as String:
            try container.encode(value, forKey: .value)
        case let value as Double:
            try container.encode(value, forKey: .value)
        case let value as Bool:
            try container.encode(value, forKey: .value)
        case let value as Date:
            try container.encode(value, forKey: .value)
        default:
            break
        }
    }
}
