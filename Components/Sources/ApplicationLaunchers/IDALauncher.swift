#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftCommand

class IDALauncherSupportManager {
    static let shared = IDALauncherSupportManager()

    static var idaLauncherSupportDirectoryURL: URL? {
        guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }
        let currentApplicationSupportDirectory = applicationSupportDirectory.appendingPathComponent(bundleIdentifier)
        let idaLauncherSupportDirectory = currentApplicationSupportDirectory.appendingPathComponent("IDALauncherSupport")
        return idaLauncherSupportDirectory
    }

    private let supportDirectoryURL: URL

    private init?() {
        guard let idaLauncherSupportDirectory = Self.idaLauncherSupportDirectoryURL else { return nil }
        if !FileManager.default.fileExists(atPath: idaLauncherSupportDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: idaLauncherSupportDirectory, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        self.supportDirectoryURL = idaLauncherSupportDirectory
    }

    func targetItem(at url: URL) -> URL {
        supportDirectoryURL.appendingPathComponent(url.lastPathComponent)
    }
    
    func copyItemToSupport(at url: URL) throws {
        try FileManager.default.copyItem(at: url.resolvingSymlinksInPath(), to: targetItem(at: url))
    }

    func removeItemFromSupport(at url: URL) throws {
        try FileManager.default.removeItem(at: targetItem(at: url))
    }
}

public struct IDALauncher {
    private static let bundleIdentifier = "com.hexrays.ida64"

    private static var directoryURLs = searchIDADirectoryURLs()

    public static var isAvailable: Bool { !directoryURLs.isEmpty }

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
        case createSupportDirectoryFailure
        case processError(String)
    }

    public let executableURL: URL

    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    private static let idaUserDirectoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".idapro")

    public func run(isCopyToTemp: Bool = true, completion: @escaping (_ result: Result<Void, Swift.Error>) -> Void) {
        guard let idaDirectory = Self.directoryURLs.first,
              let bundle = Bundle(url: idaDirectory.appendingPathComponent("ida64.app")),
              let idaExecutableURL = bundle.executableURL
        else {
            completion(.failure(Error.idaNotFound))
            return
        }
        guard let supportManager = IDALauncherSupportManager.shared else {
            completion(.failure(Error.createSupportDirectoryFailure))
            return
        }
        DispatchQueue.global().async {
            do {
                if isCopyToTemp {
                    try supportManager.copyItemToSupport(at: executableURL)
                }
                let process = Process()
                process.arguments = [supportManager.targetItem(at: executableURL).path]
                process.executableURL = idaExecutableURL
                process.environment = [
                    "__CFBundleIdentifier": "com.apple.Terminal",
                    "IDAUSR": Self.idaUserDirectoryURL.path,
                ]
                let errorPipe = Pipe()
                process.standardError = errorPipe
                process.terminationHandler = { _ in
                    do {
                        try supportManager.removeItemFromSupport(at: executableURL)
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
