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

public struct Condition {
    public enum Predicate: String, Codable, CaseIterable {
        case equals
        case doesNotEqual
        case isGreaterThan
        case isLessThan
        case isSet
        case isNotSet
        case isTrue
        case isFalse
    }
    
    public var keyPath: String
    public var predicate: Predicate
    public var value: Any?
    
    public init(keyPath: String, predicate: Predicate, value: Any? = nil) {
        self.keyPath = keyPath
        self.predicate = predicate
        self.value = value
    }
}

// MARK: - Evaluation

extension Condition {
    public func isSatisfied(data: Any?, properties: MainComponent.Properties) -> Bool {
        let lhs = JSONSerialization.value(
            forKeyPath: keyPath,
            data: data,
            properties: properties
        )
        
        switch (predicate, self.value) {
        case (.equals, let value as String):
            let maybeValue = try? value.evaluatingExpressions(
                data: data,
                properties: properties
            )
            
            guard let rhs = maybeValue else {
                return false
            }
            
            return evaluate(lhs, equals: rhs)
        case (.equals, let rhs as Double):
            return evaluate(lhs, equals: rhs)
        case (.doesNotEqual, let value as String):
            let maybeValue = try? value.evaluatingExpressions(
                data: data,
                properties: properties
            )
            
            guard let rhs = maybeValue else {
                return true
            }
            
            return evaluate(lhs, doesNotEqual: rhs)
        case (.doesNotEqual, let rhs as Double):
            return evaluate(lhs, doesNotEqual: rhs)
        case (.isGreaterThan, let rhs as Double):
            return evaluate(lhs, isGreaterThan: rhs)
        case (.isLessThan, let rhs as Double):
            return evaluate(lhs, isLessThan: rhs)
        case (.isSet, _):
            return evaluate(isSet: lhs)
        case (.isNotSet, _):
            return evaluate(isNotSet: lhs)
        case (.isTrue, _):
            return evaluate(isTrue: lhs)
        case (.isFalse, _):
            return evaluate(isFalse: lhs)
        default:
            return false
        }
    }
    
    private func evaluate(_ lhs: Any?, equals rhs: String) -> Bool {
        guard let lhs = lhs as? String else {
            return false
        }
        
        return lhs == rhs
    }
    
    private func evaluate(_ lhs: Any?, equals rhs: Double) -> Bool {
        switch lhs {
        case let lhs as Double:
            return lhs == rhs
        case let lhs as String:
            return Double(lhs) == rhs
        default:
            return false
        }
    }
    
    private func evaluate(_ lhs: Any?, doesNotEqual rhs: String) -> Bool {
        guard let lhs = lhs as? String else {
            return true
        }
        
        return lhs != rhs
    }
    
    private func evaluate(_ lhs: Any?, doesNotEqual rhs: Double) -> Bool {
        switch lhs {
        case let lhs as Double:
            return lhs != rhs
        case let lhs as String:
            return Double(lhs) != rhs
        default:
            return true
        }
    }
    
    private func evaluate(_ lhs: Any?, isGreaterThan rhs: Double) -> Bool {
        switch lhs {
        case let lhs as Double:
            return lhs > rhs
        case let lhs as String:
            guard let lhs = Double(lhs) else {
                return false
            }
            
            return lhs > rhs
        default:
            return false
        }
    }
    
    private func evaluate(_ lhs: Any?, isLessThan rhs: Double) -> Bool {
        switch lhs {
        case let lhs as Double:
            return lhs < rhs
        case let lhs as String:
            guard let lhs = Double(lhs) else {
                return false
            }
            
            return lhs < rhs
        default:
            return false
        }
    }
    
    private func evaluate(isSet value: Any?) -> Bool {
        switch value {
        case let value?:
            return !(value is NSNull)
        case .none:
            return false
        }
    }
    
    private func evaluate(isNotSet value: Any?) -> Bool {
        switch value {
        case let value?:
            return value is NSNull
        case .none:
            return true
        }
    }
    
    private func evaluate(isTrue value: Any?) -> Bool {
        switch value {
        case let value as Bool:
            return value == true
        case let value as String:
            return value == "true"
        default:
            return false
        }
    }

    private func evaluate(isFalse value: Any?) -> Bool {
        switch value {
        case let value as Bool:
            return value == false
        case let value as String:
            return value == "false"
        default:
            return false
        }
    }
}

// MARK: - Equatable

extension Condition {
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
}

// MARK: - Hashable

extension Condition: Hashable {
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
}

// MARK: - Codable

extension Condition: Codable {
    private enum CodingKeys: String, CodingKey {
        case keyPath
        case predicate
        case value
        case dataKey // Legacy
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        if coordinator.documentVersion >= 7 {
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
