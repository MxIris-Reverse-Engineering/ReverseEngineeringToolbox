import Foundation
import UniformTypeIdentifiers

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
        hasher.combine(executableURL)
    }

    public static func == (lhs: ClassDumpableFile, rhs: ClassDumpableFile) -> Bool {
        lhs.executableURL == rhs.executableURL
    }

    public var id: ClassDumpableFile { self }
}

extension ClassDumpableFile {
    public func contentType(asExecutable: Bool) -> UTType {
        switch type {
        case .framework:
            return asExecutable ? .unixExecutable : .framework
        case .executable:
            return .unixExecutable
        case .dylib:
            return .dylib
        }
    }
}

extension ClassDumpableFile {
    public func write(to destinationURL: URL) throws {
        try FileManager.default.copyItem(at: url, to: destinationURL)
    }

    public func writeExecutable(to destinationURL: URL) throws {
        try FileManager.default.copyItem(at: executableURL, to: destinationURL)
    }
}
