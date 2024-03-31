import Foundation
import Combine
import FoundationToolbox

private import Apps

public struct ClassDumpableApplication: Hashable, Identifiable {
    public struct FrameworkDirectory: Hashable {
        public let name: String
        public let frameworks: [ClassDumpableFile]
    }

    public let url: URL
    public let bundleIdentifier: String
    public let executable: ClassDumpableFile
    public let frameworkDirectories: [FrameworkDirectory]
    public var displayName: String { FileManager.default.displayName(atPath: url.path) }
    public var id: Self { self }
}

public protocol ClassDumpApplicationsControllerDelegate: AnyObject {
    func classDumpApplicationsController(_ controller: ClassDumpApplicationsController, didSearchApplications applications: [ClassDumpableApplication])
}

public final class ClassDumpApplicationsController {
    public weak var delegate: ClassDumpApplicationsControllerDelegate?

    private var cancellables: Set<AnyCancellable> = []

    @RecursiveLock
    public private(set) var applications: [ClassDumpableApplication] = []

    private let fileManager = FileManager.default

    private let queue = DispatchQueue(label: "com.JH.ClassDumpApplicationsController.Queue")

    public init() {}

    public func searchApplications() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            let searchedApplications = ApplicationController.loadApplications()
            var resultApplications: [ClassDumpableApplication] = []
            for application in searchedApplications {
                guard let bundle = Bundle(path: application.path), let executableURL = bundle.executableURL else { continue }
                let applicationURL = URL(fileURLWithPath: application.path)
                var frameworksDirectories: [ClassDumpableApplication.FrameworkDirectory] = []

                func scanFrameworkDirectories(_ frameworkDirectoryURL: URL?) {
                    if let frameworkDirectoryURL, self.fileManager.fileExists(atPath: frameworkDirectoryURL.path) {
                        frameworksDirectories.append(.init(name: frameworkDirectoryURL.lastPathComponent, frameworks: frameworkDirectoryURL.parseDumpableFileInDirectory(options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])))
                    }
                }

                scanFrameworkDirectories(bundle.privateFrameworksURL)
                scanFrameworkDirectories(bundle.sharedFrameworksURL)

                if application.bundleIdentifier == "com.apple.dt.Xcode" {
                    let contentsDirectoryURL = applicationURL.appendingPathComponent("Contents")
                    scanFrameworkDirectories(contentsDirectoryURL.appendingPathComponent("OtherFrameworks"))
                    scanFrameworkDirectories(contentsDirectoryURL.appendingPathComponent("PrivateFrameworks"))
                    scanFrameworkDirectories(contentsDirectoryURL.appendingPathComponent("SystemFrameworks"))
                }

                resultApplications.append(
                    ClassDumpableApplication(
                        url: applicationURL,
                        bundleIdentifier: application.bundleIdentifier,
                        executable: .init(executableURL: executableURL),
                        frameworkDirectories: frameworksDirectories
                    )
                )
            }
            self.applications = resultApplications
            DispatchQueue.main.async {
                self.delegate?.classDumpApplicationsController(self, didSearchApplications: resultApplications)
            }
        }
    }
}
