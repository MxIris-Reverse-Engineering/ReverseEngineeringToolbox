import Foundation

public enum ClassDumpingState {
    case ready
    case loading
    case failure
    case success
}

public enum ClassDumpableFileType {
    case framework
    case executable
}

public class ClassDumpableFile {
    public let url: URL

    public let executableURL: URL

    public let type: ClassDumpableFileType

    public var state: ClassDumpingState = .ready

    public var filename: String { url.lastPathComponent }

    public init(executableURL: URL) {
        self.url = executableURL
        self.executableURL = executableURL
        self.type = .executable
    }

    public init(url: URL, executableURL: URL, type: ClassDumpableFileType) {
        self.url = url
        self.executableURL = executableURL
        self.type = type
    }
}
