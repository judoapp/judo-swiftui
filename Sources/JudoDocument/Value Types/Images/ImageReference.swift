import SwiftUI

public enum ImageReference: Codable, Hashable, CustomStringConvertible {
    case document(imageName: String)
    case system(imageName: String)
    case inline(image: SwiftUI.Image)
    
    public var name: String {
        switch self {
        case .document(let imageName):
            return imageName
        case .system(let imageName):
            return imageName
        case .inline:
            return "Image"
        }
    }

    public var description: String {
        name
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .document(let imageName):
            hasher.combine("document")
            hasher.combine(imageName)
        case .system(let imageName):
            hasher.combine("system")
            hasher.combine(imageName)
        case .inline:
            hasher.combine("inline")
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: CodingKey {
        case document
        case system
        case inline
    }
    
    enum DocumentCodingKeys: CodingKey {
        case imageName
    }
    
    enum SystemCodingKeys: CodingKey {
        case imageName
    }
    
    enum InlineCodingKeys: CodingKey {
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ImageReference.CodingKeys> = try decoder.container(keyedBy: ImageReference.CodingKeys.self)
        
        var allKeys: ArraySlice<ImageReference.CodingKeys> = ArraySlice<ImageReference.CodingKeys>(container.allKeys)
        
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(ImageReference.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .document:
            
            let nestedContainer: KeyedDecodingContainer<ImageReference.DocumentCodingKeys> = try container.nestedContainer(keyedBy: ImageReference.DocumentCodingKeys.self, forKey: ImageReference.CodingKeys.document)
            
            self = ImageReference.document(imageName: try nestedContainer.decode(String.self, forKey: ImageReference.DocumentCodingKeys.imageName))
        case .system:
            
            let nestedContainer: KeyedDecodingContainer<ImageReference.SystemCodingKeys> = try container.nestedContainer(keyedBy: ImageReference.SystemCodingKeys.self, forKey: ImageReference.CodingKeys.system)
            
            self = ImageReference.system(imageName: try nestedContainer.decode(String.self, forKey: ImageReference.SystemCodingKeys.imageName))
        case .inline:
            
            _ = try container.nestedContainer(keyedBy: ImageReference.InlineCodingKeys.self, forKey: ImageReference.CodingKeys.inline)
            
            #if os(macOS)
            let emptyImage = SwiftUI.Image(nsImage: NSImage(size: .zero))
            #else
            let emptyImage = SwiftUI.Image(uiImage: UIImage())
            #endif
            self = ImageReference.inline(image: emptyImage)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<ImageReference.CodingKeys> = encoder.container(keyedBy: ImageReference.CodingKeys.self)
        
        switch self {
        case .document(let imageName):
            
            var nestedContainer: KeyedEncodingContainer<ImageReference.DocumentCodingKeys> = container.nestedContainer(keyedBy: ImageReference.DocumentCodingKeys.self, forKey: ImageReference.CodingKeys.document)
            
            try nestedContainer.encode(imageName, forKey: ImageReference.DocumentCodingKeys.imageName)
        case .system(let imageName):
            
            var nestedContainer: KeyedEncodingContainer<ImageReference.SystemCodingKeys> = container.nestedContainer(keyedBy: ImageReference.SystemCodingKeys.self, forKey: ImageReference.CodingKeys.system)
            
            try nestedContainer.encode(imageName, forKey: ImageReference.SystemCodingKeys.imageName)
        case .inline:
            
            _ = container.nestedContainer(keyedBy: ImageReference.InlineCodingKeys.self, forKey: ImageReference.CodingKeys.inline)
            break
        }
    }
}

extension ImageReference {
    public static var `default`: ImageReference {
        .system(imageName: "globe")
    }
    
    public static var empty: ImageReference {
        .system(imageName: "square.dashed")
    }
}
