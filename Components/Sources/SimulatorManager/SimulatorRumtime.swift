import Foundation

public struct SimulatorRumtime: Hashable, Identifiable {
    public let systemVersion: SimulatorSystemVersion
    public let path: String
    public let runtimeRootPath: String

    public var readableString: String {
        "\(systemVersion.productName) \(systemVersion.productVersion) (\(systemVersion.productBuildVersion))"
    }

    public var id: Self { self }
    
    public var platform: Platform {
        .init(rawValue: systemVersion.productName) ?? .unknown
    }
    
    public enum Platform: String, CaseIterable, Hashable {
        case iOS = "iPhone OS"
        case watchOS = "Watch OS"
        case tvOS = "Apple TVOS"
        case xrOS = "xrOS"
        case unknown = ""
    }
    
    
    public var availablePaths: [String] {
        var paths: [String] = [
            "Applications",
            "System/Library/Frameworks",
            "System/Library/PrivateFrameworks",
            "System/Library/HIDPlugins/ServicePlugins",
            "usr/lib",
            "usr/bin",
            "usr/sbin"
        ]
        if platform == .tvOS {
            paths.append("System/Library/TVSystemMenuModules")
        }
        return paths
    }
}
