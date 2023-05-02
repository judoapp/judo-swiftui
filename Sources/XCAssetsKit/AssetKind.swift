import Foundation

public enum AssetKind: String, Codable, CaseIterable {
    case imageSet

    public init?(folderExtension: String) {
        switch folderExtension {
        case "imageset":
            self = .imageSet
        default:
            return nil
        }
    }

    public var folderExtension: String {
        switch self {
        case .imageSet:
            return "imageset"
        }
    }
}

extension Asset {

    public var kind: AssetKind {
        switch self {
        case is ImageSet:
            return .imageSet
        default:
            fatalError("Unexpected")
        }
    }

}
