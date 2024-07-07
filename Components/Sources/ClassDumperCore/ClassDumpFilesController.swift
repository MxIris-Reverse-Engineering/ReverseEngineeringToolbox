import Foundation
import ClassDump
import ExceptionCatcher
import FrameworkToolbox
import FoundationToolbox
import UniformTypeIdentifiers

public protocol ClassDumpFilesControllerDelegate: AnyObject {
    func classDumpFilesController(_ controller: ClassDumpFilesController, willParseSourceURL url: URL)
    func classDumpFilesController(_ controller: ClassDumpFilesController, didSelectSourceURL url: URL)
    func classDumpFilesController(_ controller: ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumpableFile)
    func classDumpFilesController(_ controller: ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumpableFile)
    func classDumpFilesControllerWillStartPerform(_ controller: ClassDumpFilesController)
    func classDumpFilesControllerDidCompletePerform(_ controller: ClassDumpFilesController)
}

public final class ClassDumpFilesController: ClassDumpFileControllerDelegate {
    public weak var delegate: ClassDumpFilesControllerDelegate?

    public private(set) var currentSourceURL: URL?

    public private(set) var isDirectory: Bool = false
    
    @RecursiveLock
    public private(set) var parsedDumpableFiles: [ClassDumpableFile] = []

    @RecursiveLock
    public private(set) var completedDumpableFiles: [ClassDumpableFile] = []

    private let fileManager = FileManager.default

    private let serialQueue = DispatchQueue(label: "com.JH.ClassDumper.ClassDumpController.serialQueue")

    private let concurrentQueue = DispatchQueue(label: "com.JH.ClassDumper.ClassDumpController.concurrentQueue", attributes: .concurrent)

    private let group = DispatchGroup()

    private let classDumpFileController: ClassDumpFileController

    public init(configuration: CDClassDumpConfiguration) {
        self.classDumpFileController = ClassDumpFileController(configuration: configuration)
        classDumpFileController.delegate = self
    }

    public func selectSourceURL(_ url: URL, searchLevel: Int = 1) {
        guard let contentType = url.contentType else { return }
        parsedDumpableFiles = []
        currentSourceURL = url
        isDirectory = contentType == .folder
        if isDirectory {
            delegate?.classDumpFilesController(self, willParseSourceURL: url)
            serialQueue.async {
                let dumpableFiles = url.parseDumpableFileInDirectory(options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
                self.parsedDumpableFiles.append(contentsOf: dumpableFiles)
                DispatchQueue.main.async {
                    self.parsedDumpableFiles.sort(for: \.executableURL.lastPathComponent, by: <)
                    self.delegate?.classDumpFilesController(self, didSelectSourceURL: url)
                }
            }
        } else {
            delegate?.classDumpFilesController(self, willParseSourceURL: url)
            url.parseDumpableFile().map { parsedDumpableFiles.append($0) }
            delegate?.classDumpFilesController(self, didSelectSourceURL: url)
        }
    }

    public func perform(for dumpableFile: ClassDumpableFile, to destinationRootURL: URL) {
        serialQueue.async {
            self.classDumpFileController.perform(for: dumpableFile, to: destinationRootURL)
        }
    }

    public func perform(for currentDestinationURL: URL) {
        guard currentSourceURL != nil, !parsedDumpableFiles.isEmpty else { return }
        completedDumpableFiles = []
        delegate?.classDumpFilesControllerWillStartPerform(self)
        for (_, parsedDumpableFile) in parsedDumpableFiles.enumerated() {
            concurrentQueue.async(group: group) {
                self.classDumpFileController.perform(for: parsedDumpableFile, to: currentDestinationURL)
            }
        }
        group.notify(queue: .main) {
            self.delegate?.classDumpFilesControllerDidCompletePerform(self)
        }
    }

    public func classDumpFileController(_ controller: ClassDumpFileController, willStartDumpableFile dumpableFile: ClassDumpableFile) {
        delegate?.classDumpFilesController(self, willStartDumpableFile: dumpableFile)
    }

    public func classDumpFileController(_ controller: ClassDumpFileController, didCompleteDumpableFile dumpableFile: ClassDumpableFile) {
        completedDumpableFiles.append(dumpableFile)
        delegate?.classDumpFilesController(self, didCompleteDumpableFile: dumpableFile)
    }
}

extension Array {
    mutating func sort<Value: Comparable>(for keyPath: KeyPath<Element, Value>, by areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows {
        try sort(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
}

func print(_ item: Any?) -> Bool {
    print(item as Any)
    return true
}

extension UTType {
    public static let dylib = UTType("com.apple.mach-o-dylib")!
    public static let machOBinary = UTType("com.apple.mach-o-binary")!
}

extension URL {
    func parseDumpableFileInDirectory(options: FileManager.DirectoryEnumerationOptions) -> [ClassDumpableFile] {
        box.enumerator(options: options).compactMap { $0.parseDumpableFile() }
    }

    func parseDumpableFile() -> ClassDumpableFile? {
        guard let contentType = contentType else { return nil }
        switch contentType {
        case .framework:
            if let framework = Bundle(url: self), let executableURL = framework.executableURL {
                return .init(url: self, executableURL: executableURL, type: .framework)
            }
        case .unixExecutable:
            return .init(url: self, executableURL: self, type: .executable)
        case .dylib:
            return .init(url: self, executableURL: self, type: .dylib)
        default:
            break
        }
        return nil
    }

    var contentType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }
}
