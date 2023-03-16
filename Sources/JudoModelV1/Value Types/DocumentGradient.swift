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

public final class DocumentGradient: ObservableObject, Codable, Equatable, Dependable, Hashable {
    public init(id: DocumentGradient.ID = UUID(), name: String = "", gradient: GradientValue, variants: [Set<DocumentGradient.Selector> : GradientValue] = [:]) {
        self.id = id
        self.name = name
        self.gradient = gradient
        self.variants = variants
    }
    
    public static func == (lhs: DocumentGradient, rhs: DocumentGradient) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name // TODO: add missing fields?
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(gradient)
        hasher.combine(variants)
    }

    public typealias ID = UUID
    
    @Published public var id: ID = UUID()
    @Published public var name: String = ""
    
    /// The base gradient, equivalent to Light Mode, in Normal Contrast mode.  If none of the variant selectors match, it is this one that is selected.
    @Published public var gradient: GradientValue
    @Published public var variants: [Set<Selector>: GradientValue]
    
    public enum Selector: String, Hashable {
        case darkMode = "darkMode"
        case highContrast = "highContrast"
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case `default`
        case darkMode
        case highContrast
        case darkModeHighContrast
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(gradient, forKey: .default)
        
        try variants.forEach { selectors, value in
            if selectors.contains(.darkMode) && selectors.contains(.highContrast) {
                try container.encodeIfPresent(value, forKey: .darkModeHighContrast)
            } else if selectors.contains(.darkMode) {
                try container.encodeIfPresent(value, forKey: .darkMode)
            } else if selectors.contains(.highContrast) {
                try container.encodeIfPresent(value, forKey: .highContrast)
            }
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        gradient = try container.decode(GradientValue.self, forKey: .default)
        variants = [Set<Selector>: GradientValue]()
        
        if container.contains(.darkMode) {
            variants[[.darkMode]] = try container.decode(GradientValue.self, forKey: .darkMode)
        }
        
        if container.contains(.highContrast) {
            variants[[.highContrast]] = try container.decode(GradientValue.self, forKey: .highContrast)
        }
        
        if container.contains(.darkModeHighContrast) {
            variants[[.darkMode, .highContrast]] = try container.decode(GradientValue.self, forKey: .darkModeHighContrast)
        }
    }
    
    // MARK: Resolution
    
    public func resolveGradient(darkMode: Bool = false, highContrast: Bool = false) -> GradientValue {
        // prefer tightest match of selectors.  Fault backwards through tightest matches of selectors until getting to the base gradient.
        let variant: GradientValue?
        if darkMode, highContrast {
            variant = variants[[.darkMode, .highContrast]] ?? variants[[.darkMode]] ?? variants[[.highContrast]]
        } else if darkMode {
            variant = variants[[.darkMode]]
        } else if highContrast {
            variant = variants[[.highContrast]]
        } else {
            variant = nil
        }
        return variant ?? gradient
    }
}
