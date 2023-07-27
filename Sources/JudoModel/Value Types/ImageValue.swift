import SwiftUI

public enum ImageValue: Codable, Hashable {
    case reference(imageReference: ImageReference)
    case property(propertyName: String)
    case fetchedImage
    
    public func resolve(properties: MainComponent.Properties, fetchedImage: SwiftUI.Image?) -> ImageReference? {
        switch self {
        case .reference(let imageReference):
            return imageReference
        case .property(let propertyName):
            switch properties[propertyName] {
            case .image(let imageReference):
                return imageReference
            default:
                return nil
            }
        case .fetchedImage:
            if let fetchedImage {
                return ImageReference.inline(image: fetchedImage)
            } else {
                return nil
            }
        }
    }
}

extension ImageValue {
    public static var `default`: ImageValue {
        .reference(imageReference: .default)
    }
}
