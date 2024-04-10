#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftCommand

public struct IDALauncher {
    public static var isAvailable: Bool {
        !directoryURLs.isEmpty
    }

    private static let bundleIdentifier = "com.hexrays.ida64"

    private static var directoryURLs = searchIDADirectoryURLs()

    private static func searchIDADirectoryURLs() -> [URL] {
        var searchedURLs: [URL] = []
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        if let urls = try? FileManager.default.contentsOfDirectory(at: applicationsURL, includingPropertiesForKeys: nil) {
            for url in urls {
                if url.lastPathComponent.contains("IDA") {
                    searchedURLs.append(url)
                }
            }
        }
        return searchedURLs
    }

    public enum Error: Swift.Error {
        case idaNotFound
        case processError(String)
    }

    public let executableURL: URL

    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    public func run(isCopyToTemp: Bool = true, completion: @escaping (_ result: Result<Void, Swift.Error>) -> Void) {
        guard let idaDirectory = Self.directoryURLs.first,
              let bundle = Bundle(url: idaDirectory.appendingPathComponent("ida64.app")),
              let idaExecutableURL = bundle.executableURL
        else {
            completion(.failure(Error.idaNotFound))
            return
        }
        DispatchQueue.global().async {
            do {
                var finalExecutableURL = executableURL
                if isCopyToTemp {
                    let dumpTempURL = FileManager.default.temporaryDirectory.appendingPathComponent("IDADumpTemp")
                    if !FileManager.default.fileExists(atPath: dumpTempURL.path) {
                        try FileManager.default.createDirectory(at: dumpTempURL, withIntermediateDirectories: true)
                    }
                    finalExecutableURL = dumpTempURL.appendingPathComponent(executableURL.lastPathComponent)
                    if FileManager.default.fileExists(atPath: finalExecutableURL.path) {
                        try FileManager.default.removeItem(at: finalExecutableURL)
                    }

                    try FileManager.default.copyItem(at: executableURL.resolvingSymlinksInPath(), to: finalExecutableURL)
                }
                let process = Process()
                process.arguments = [finalExecutableURL.path]
                process.executableURL = idaExecutableURL
                process.environment = [
                    "__CFBundleIdentifier": "com.apple.Terminal",
                    "IDAUSR": FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".idapro").path,
                ]
                let errorPipe = Pipe()
                process.standardError = errorPipe
                print("Final Executable URL: \(finalExecutableURL.path)")
                process.terminationHandler = { _ in
                    do {
                        try FileManager.default.removeItem(at: finalExecutableURL)
                    } catch {
                        print(error)
                    }
                }
                try process.run()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

#endif
