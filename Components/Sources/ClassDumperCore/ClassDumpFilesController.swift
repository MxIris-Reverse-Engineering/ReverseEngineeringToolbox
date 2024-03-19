import AppKit
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

public final class ClassDumpFilesController {
    public weak var delegate: ClassDumpFilesControllerDelegate?

    public private(set) var currentSourceURL: URL?

    public private(set) var currentSourceFileWrapper: FileWrapper?

    public private(set) var isDirectory: Bool = false

    @RecursiveLock
    public private(set) var parsedDumpableFiles: [ClassDumpableFile] = []

    @RecursiveLock
    public private(set) var completedDumpableFiles: [ClassDumpableFile] = []

    private let fileManager = FileManager.default

    private let serialQueue = DispatchQueue(label: "com.JH.ClassDumper.ClassDumpController.serialQueue")

    private let concurrentQueue = DispatchQueue(label: "com.JH.ClassDumper.ClassDumpController.concurrentQueue", attributes: .concurrent)

    private let group = DispatchGroup()

    public init() {}

    public func showInFinder() {
        guard let currentSourceURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([currentSourceURL])
    }

    public func selectSourceURL(_ url: URL) throws {
        parsedDumpableFiles = []
        currentSourceURL = url
        let currentSourceFileWrapper = try FileWrapper(url: url)
        self.currentSourceFileWrapper = currentSourceFileWrapper
        if currentSourceFileWrapper.isDirectory, url.lastPathComponent.pathExtension != "framework" {
            delegate?.classDumpFilesController(self, willParseSourceURL: url)
            serialQueue.async {
                for childrenURL in url.box.enumerator(options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]) {
                    self.parseURLContent(childrenURL)
                }

                DispatchQueue.main.async {
                    self.parsedDumpableFiles.sort(for: \.executableURL.lastPathComponent, by: <)
                    self.delegate?.classDumpFilesController(self, didSelectSourceURL: url)
                }
            }
        } else {
            delegate?.classDumpFilesController(self, willParseSourceURL: url)
            parseURLContent(url)
            delegate?.classDumpFilesController(self, didSelectSourceURL: url)
        }
    }

    private func parseURLContent(_ url: URL) {
        if let contentType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
            switch contentType {
            case .framework:
                for childrenURL in url.box.enumerator(options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]) {
                    if let fileWrapper = try? FileWrapper(url: childrenURL) {
                        if fileWrapper.isSymbolicLink, let symbolicLinkDestinationURL = fileWrapper.symbolicLinkDestinationURL {
                            let symbolicLinkDestinationFullURL = url.appendingPathComponent(symbolicLinkDestinationURL.path)
                            if let contentType = try? symbolicLinkDestinationFullURL.resourceValues(forKeys: [.contentTypeKey]).contentType {
                                if contentType == .unixExecutable {
                                    parsedDumpableFiles.append(.init(url: url, executableURL: symbolicLinkDestinationFullURL, type: .framework))
                                    continue
                                }
                            }
                        }
                    }
                    if let contentType = try? childrenURL.resourceValues(forKeys: [.contentTypeKey]).contentType, contentType == .unixExecutable {
                        parsedDumpableFiles.append(.init(url: url, executableURL: childrenURL, type: .framework))
                    }
                }
            case .unixExecutable:
                parsedDumpableFiles.append(.init(url: url, executableURL: url, type: .executable))
            case .dylib:
                parsedDumpableFiles.append(.init(url: url, executableURL: url, type: .dylib))
            default:
                break
            }
        }
    }

    public func perform(for dumpableFile: ClassDumpableFile, to destinationRootURL: URL) {
        serialQueue.async {
            self._perform(for: dumpableFile, to: destinationRootURL)
        }
    }

    public func perform(for currentDestinationURL: URL) {
        guard currentSourceURL != nil, !parsedDumpableFiles.isEmpty else { return }
        completedDumpableFiles = []
        delegate?.classDumpFilesControllerWillStartPerform(self)
        for (index, parsedDumpableFile) in parsedDumpableFiles.enumerated() {
            concurrentQueue.async(group: group) {
                self._perform(for: parsedDumpableFile, to: currentDestinationURL)
            }
        }
        group.notify(queue: .main) {
            self.delegate?.classDumpFilesControllerDidCompletePerform(self)
        }
    }

    private func _perform(for dumpableFile: ClassDumpableFile, to destinationRootURL: URL) {
        assert(!Thread.isMainThread, "This function cannot be called from the main thread")
        let sourcePath = dumpableFile.executableURL.path
        let destinationPath = destinationRootURL.appendingPathComponent(sourcePath.lastPathComponent.deletingPathExtension).path
        if !fileManager.fileExists(atPath: destinationPath) {
            try? fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true)
        }
        do {
            DispatchQueue.main.sync {
                dumpableFile.state = .loading
                self.delegate?.classDumpFilesController(self, willStartDumpableFile: dumpableFile)
            }
            try ExceptionCatcher.catch { try ClassDumpManager.shared.performClassDump(onFile: sourcePath, toFolder: destinationPath) }
            DispatchQueue.main.sync {
                dumpableFile.state = .success
                self.completedDumpableFiles.append(dumpableFile)
                self.delegate?.classDumpFilesController(self, didCompleteDumpableFile: dumpableFile)
            }
        } catch {
            print(error.localizedDescription)
            debugPrint(error)
            DispatchQueue.main.sync {
                dumpableFile.state = .failure
                self.completedDumpableFiles.append(dumpableFile)
                self.delegate?.classDumpFilesController(self, didCompleteDumpableFile: dumpableFile)
            }
        }
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
    static let dylib = UTType("com.apple.mach-o-dylib")!
}
