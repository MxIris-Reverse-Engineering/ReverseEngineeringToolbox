import AppKit
import ClassDump
import ExceptionCatcher
import FrameworkToolbox
import FoundationToolbox

public protocol ClassDumpFilesControllerDelegate: AnyObject {
    func classDumpFilesController(_ controller: ClassDumpFilesController, didSelectSourceURL url: URL)
    func classDumpFilesController(_ controller: ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumpableFile, atIndex index: Int)
    func classDumpFilesController(_ controller: ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumpableFile, atIndex index: Int)
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
                                }
                            }
                        }
                    }
                }
            case .unixExecutable:
                parsedDumpableFiles.append(.init(url: url, executableURL: url, type: .executable))
            default:
                break
            }
        }
    }

    public func perform(for currentDestinationURL: URL) {
        guard currentSourceURL != nil, !parsedDumpableFiles.isEmpty else { return }
        completedDumpableFiles = []
        delegate?.classDumpFilesControllerWillStartPerform(self)
        for (index, parsedDumpableFile) in parsedDumpableFiles.enumerated() {
            concurrentQueue.async(group: group) {
                let sourcePath = parsedDumpableFile.executableURL.path
                let destinationPath = currentDestinationURL.appendingPathComponent(sourcePath.lastPathComponent.deletingPathExtension).path
                if !self.fileManager.fileExists(atPath: destinationPath) {
                    try? self.fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true)
                }
                do {
                    DispatchQueue.main.sync {
                        parsedDumpableFile.state = .loading
                        self.delegate?.classDumpFilesController(self, willStartDumpableFile: parsedDumpableFile, atIndex: index)
                    }
                    try ExceptionCatcher.catch { try ClassDumpManager.shared.performClassDump(onFile: sourcePath, toFolder: destinationPath) }
                    DispatchQueue.main.sync {
                        parsedDumpableFile.state = .success
                        self.completedDumpableFiles.append(parsedDumpableFile)
                        self.delegate?.classDumpFilesController(self, didCompleteDumpableFile: parsedDumpableFile, atIndex: index)
                    }
                } catch {
                    print(error.localizedDescription)
                    debugPrint(error)
                    DispatchQueue.main.sync {
                        parsedDumpableFile.state = .failure
                        self.completedDumpableFiles.append(parsedDumpableFile)
                        self.delegate?.classDumpFilesController(self, didCompleteDumpableFile: parsedDumpableFile, atIndex: index)
                    }
                }
            }
        }
        group.notify(queue: .main) {
            self.delegate?.classDumpFilesControllerDidCompletePerform(self)
        }
    }
}

extension Array {
    mutating func sort<Value: Comparable>(for keyPath: KeyPath<Element, Value>, by areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows {
        try sort(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
}
