import Foundation
public struct SimulatorSystemVersion: Codable {
    public let buildID: String
    public let productBuildVersion: String
    public let productCopyright: String
    public let productName: String
    public let productVersion: String

    public enum CodingKeys: String, CodingKey {
        case buildID = "BuildID"
        case productBuildVersion = "ProductBuildVersion"
        case productCopyright = "ProductCopyright"
        case productName = "ProductName"
        case productVersion = "ProductVersion"
    }
}
