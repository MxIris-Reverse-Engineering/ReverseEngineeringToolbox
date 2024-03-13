import Foundation

public struct SimulatorImage: Codable {
    public struct Path: Codable {
        public let relative: String
    }

    public struct RuntimeInfo: Codable {
        public let build: String
        public let bundleIdentifier: String
        public let bundlePath: Path
        public let isInternal: Bool
        public let platformIdentifier: String
        public let version: Int
    }

    ///    let format: Format
    public let lastUsedAt: Date?
    ///    let mountPolicy: MountPolicy
    public let path: Path
    public let runtimeInfo: RuntimeInfo
    ///    let signatureState: SignatureState
    public let sourceURL: Path
    public let state: Int
    public let uuid: String
    ///    let writePolicy: WritePolicy
    public let userInfoData: Data?
}

public struct SimulatorImageList: Codable {
    public let images: [SimulatorImage]
}
