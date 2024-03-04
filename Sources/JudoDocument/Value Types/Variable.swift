import Foundation
import SwiftUI

/// Variable
public struct Variable<T: Codable & Hashable & CustomStringConvertible>: Codable, Hashable, CustomStringConvertible {

    /// Variable Binding
    ///
    /// A reference to the name of the component property, the key path to a data property or a reference to the fetched image data.
    public enum Binding: Codable, Hashable, CustomStringConvertible {
        /// Reference to the name of the component property
        case property(name: String)
        /// Key path to a data property
        case data(keyPath: String)

        case fetchedImage
        
        public var description: String {
            switch self {
            case .property(let name):
                return name
            case .data(let keyPath):
                return keyPath
            case .fetchedImage:
                return "Fetched Image"
            }
        }
        
        func resolve(propertyValues: [String: PropertyValue], data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) -> T? {
            switch self {
            case .property(let name):
                guard let property = propertyValues[name] else {
                    return nil
                }
                
                switch (property, T.self) {
                    
                // String
                case (.text(let value), is String.Type):
                    return value as? T
                case (.number(let value), is String.Type):
                    if #available(macOS 12.0, iOS 15.0, *) {
                        return value.formatted() as? T
                    } else {
                        return value.description as? T
                    }
                    
                // Double
                case (.number(let value), is Double.Type):
                    return value as? T
                    
                // Bool
                case (.boolean(let value), is Bool.Type):
                    return value as? T
                case (.number(let value), is Bool.Type):
                    return NSNumber(value: value).boolValue as? T
                
                // ImageReference
                case (.image(let imageReference), is ImageReference.Type):
                    return imageReference as? T
                    
                // UUID
                case (.component(let id), is UUID.Type):
                    return id as? T

                // Video
                case (.video(let value), is Video.Type):
                    return value as? T

                case (.computed(let value), is String.Type):
                    switch value {
                    case .text(let expression):
                        return expression.resolve(propertyValues: propertyValues, data: data) as? T
                    case .number(let expression):
                        let resolvedValue = expression.resolve(propertyValues: propertyValues, data: data)
                        if #available(macOS 12.0, iOS 15.0, *) {
                            return resolvedValue?.formatted() as? T
                        } else {
                            return resolvedValue?.description as? T
                        }
                    case .boolean(let expression):
                        return expression.resolve(propertyValues: propertyValues, data: data)?.description as? T
                    }

                case (.computed(let value), is Double.Type):
                    switch value {
                    case .number(let expression):
                        return expression.resolve(propertyValues: propertyValues, data: data) as? T
                    case .text, .boolean:
                        return nil
                    }

                case (.computed(let value), is Bool.Type):
                    switch value {
                    case .boolean(let expression):
                        return expression.resolve(propertyValues: propertyValues, data: data) as? T
                    case .text, .number:
                        return nil
                    }

                default:
                    return nil
                }
            case .data(let keyPath):
                let value = JSONSerialization.value(
                    forKeyPath: keyPath,
                    data: data,
                    propertyValues: propertyValues
                )
                
                guard let value else {
                    return nil
                }
                
                switch (value, T.self) {
                    
                // String
                case (let string as NSString, is String.Type):
                    return string as? T
                case (let number as NSNumber, is String.Type):
                    if #available(macOS 12.0, iOS 15.0, *) {
                        return number.doubleValue.formatted() as? T
                    } else {
                        return number.doubleValue.description as? T
                    }
                    
                // Double
                case (let number as NSNumber, is Double.Type):
                    return number.doubleValue as? T
                    
                // Bool
                case (let bool as Bool, is Bool.Type):
                    return bool as? T
                case (let number as NSNumber, is Bool.Type):
                    return number.boolValue as? T
                    
                // ImageReference
                case (let string as String, is ImageReference.Type):
                    return ImageReference.document(imageName: string) as? T

                // Video
                case (let string as String, is Video.Type):
                    return Video(url: string) as? T

                default:
                    return nil
                }
            case .fetchedImage:
                guard let fetchedImage, T.self is ImageReference.Type else {
                    return nil
                }
                
                return ImageReference.inline(image: fetchedImage) as? T
            }
        }
    }

    /// Constant value
    ///
    /// Default value for variable
    public var constant: T

    /// Optional Binding.
    ///
    /// Either a reference to the name of the component property or the key path to a data property
    public private(set) var binding: Binding?

    public var isBinding: Bool {
        binding != nil
    }
    
    /// If the variable does not have a binding, this function simply returns its constant value. If the variable does have a binding, it will return the result of resolvling that binding using the passed in propertyValues, data and fetched image.
    public func resolve(propertyValues: [String: PropertyValue], data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) -> T? {
        if let binding {
            return binding.resolve(
                propertyValues: propertyValues,
                data: data,
                fetchedImage: fetchedImage
            )
        } else {
            return constant
        }
    }
    
    /// This function is the same in behaviour as the  `resolve(propertyValues:data:fetchedImage:)` function however it will always return a non-nil value. If the result of resolving the variable's binding is nil, then the value of the `defaultValue` argument is returned. If no `defaultArgument` is passed in to the function, then the variable's constant is returned.
    public func forceResolve(propertyValues: [String: PropertyValue], data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) -> T {
        binding?.resolve(
            propertyValues: propertyValues,
            data: data,
            fetchedImage: fetchedImage
        ) ?? constant
    }
    
    /// This function resolves the variable's binding by calling the `resolve(propertyValues:data:fetchedImage:)` function and if it resolves to a value the variable's constant value is updated with the result. If the result of resolving the binding is nil, then no update takes place.
    public mutating func updateConstant(propertyValues: [String: PropertyValue], data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) {
        guard let binding else {
            return
        }
        
        let newValue: T? = binding.resolve(
            propertyValues: propertyValues,
            data: data,
            fetchedImage: fetchedImage
        )
        
        guard let newValue else {
            return
        }
        
        constant = newValue
    }
    
    /// A non-mutating version of `resolveInPlace(propertyValues:data:fetchedImage:)` that returns a new copy of the variable instead of mutating it.
    public func withUpdatedConstant(propertyValues: [String: PropertyValue], data: Any? = nil, fetchedImage: SwiftUI.Image? = nil) -> Self {
        var copy = self
        copy.updateConstant(
            propertyValues: propertyValues,
            data: data,
            fetchedImage: fetchedImage
        )
        return copy
    }

    // Binding

    /// Bind variable to a binding
    /// - Parameter binding: A binding.
    mutating public func bind(to binding: Binding) {
        self.binding = binding
    }

    /// Bind variable to a binding.
    /// - Parameter binding: A binding.
    /// - Returns: Bound variable.
    public func bound(to binding: Binding) -> Self {
        var copy = self
        copy.bind(to: binding)
        return copy
    }

    /// Unbind variable.
    /// - Parameter constant: A constant value.
    mutating public func unbind(to constant: T) {
        self.constant = constant
        self.binding = nil
    }

    /// Unbind and update the constant value
    /// - Parameter constant: A value.
    /// - Returns: Unbound variable.
    public func unbound(to constant: T) -> Self {
        var copy = self
        copy.unbind(to: constant)
        return copy
    }

    /// Remove binding in place.
    mutating public func unbind() {
        self.binding = nil
    }

    /// Remove binding.
    /// - Returns: Unbound variable.
    public func unbound() -> Self {
        var copy = self
        copy.unbind()
        return copy
    }

    // CustomStringConvertible

    public var description: String {
        if let binding {
            return binding.description
        }
        return constant.description
    }

    // Codable

    private enum CodingKeys: String, CodingKey {
        case constant
        case binding
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        constant = try container.decode(T.self, forKey: .constant)
        binding = try container.decodeIfPresent(Binding.self, forKey: .binding)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(constant, forKey: .constant)
        try container.encodeIfPresent(binding, forKey: .binding)
    }
}

// MARK: Initializers

// String

extension Variable<String> {
    public init(_ constant: String, binding: Binding? = nil) {
        self.constant = constant
        self.binding = binding
    }
}

extension Variable<String>: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Variable<String>: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Variable<String>: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
}

// Double

extension Variable<Double> {
    public init(_ constant: Double, binding: Binding? = nil) {
        self.constant = constant
        self.binding = binding
    }
    
    public init(_ constant: CGFloat, binding: Binding? = nil) {
        let doubleValue = Double(constant)
        self.init(doubleValue)
    }
    
    public init(_ constant: Int, binding: Binding? = nil) {
        let doubleValue = Double(constant)
        self.init(doubleValue)
    }
}

extension Variable<Double>: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension Variable<Double>: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}


// Bool

extension Variable<Bool> {
    public init(_ constant: Bool, binding: Binding? = nil) where T == Bool {
        self.constant = constant
        self.binding = binding
    }
}

extension Variable<Bool>: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

// ImageReference

extension Variable<ImageReference> {
    public init(_ constant: ImageReference, binding: Binding? = nil) {
        self.constant = constant
        self.binding = binding
    }
}

// UUID

extension Variable<UUID> {
    public init(_ constant: UUID, binding: Binding? = nil) {
        self.constant = constant
        self.binding = binding
    }
}

// Video

extension Variable<Video> {
    public init(_ constant: Video, binding: Binding? = nil) {
        self.constant = constant
        self.binding = binding
    }
}

// MARK: Legacy Initialization

extension Variable<Bool> {
    init(_ booleanValue: LegacyBooleanValue) {
        switch booleanValue {
        case .constant(let value):
            self.constant = value
            self.binding = nil
        case .property(let propertyName):
            self.constant = false
            self.binding = .property(name: propertyName)
        case .data(let keyPath):
            self.constant = false
            self.binding = .data(keyPath: keyPath)
        }
    }
}

extension Variable<Double> {
    init(_ numberValue: LegacyNumberValue) {
        switch numberValue {
        case .constant(let value):
            self.constant = value
            self.binding = nil
        case .property(let propertyName):
            self.constant = 0
            self.binding = .property(name: propertyName)
        case .data(let keyPath):
            self.constant = 0
            self.binding = .data(keyPath: keyPath)
        }
    }
}

extension Variable<String> {
    init(_ textValue: LegacyTextValue) {
        switch textValue {
        case .verbatim(let value):
            self.constant = value
            self.binding = nil
        case .literal(let value):
            self.constant = value
            self.binding = nil
        case .property(let propertyName, _):
            self.constant = ""
            self.binding = .property(name: propertyName)
        case .data(let keyPath):
            self.constant = ""
            self.binding = .data(keyPath: keyPath)
        }
    }
}

extension Variable<ImageReference> {
    init(_ imageValue: LegacyImageValue) {
        switch imageValue {
        case .fetchedImage:
            self.constant = .default
            self.binding = .fetchedImage
        case .property(let propertyName):
            self.constant = .default
            self.binding = .property(name: propertyName)
        case .reference(let imageReference):
            self.constant = imageReference
            self.binding = nil
        }
    }
}
