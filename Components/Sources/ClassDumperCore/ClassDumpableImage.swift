import Foundation

public class ClassDumpableImage: Hashable, Identifiable {
    public let path: String

    public init(path: String) {
        self.path = path
    }

    public static func == (lhs: ClassDumpableImage, rhs: ClassDumpableImage) -> Bool {
        lhs.path == rhs.path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }

    public var id: ClassDumpableImage { self }
}
