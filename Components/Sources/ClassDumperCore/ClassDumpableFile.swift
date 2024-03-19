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
    case dylib
}

public class ClassDumpableFile: Hashable, Identifiable {
    
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    public static func == (lhs: ClassDumpableFile, rhs: ClassDumpableFile) -> Bool {
        lhs.url == rhs.url
    }

    public var id: ClassDumpableFile { self }
}
