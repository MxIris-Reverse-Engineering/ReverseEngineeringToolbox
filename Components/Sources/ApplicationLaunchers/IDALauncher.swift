#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftCommand

private class IDALauncherSupportManager {
    public static let shared = IDALauncherSupportManager()

    private static var idaLauncherSupportDirectoryURL: URL? {
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

    public func targetItem(at url: URL) -> URL {
        supportDirectoryURL.appendingPathComponent(url.lastPathComponent)
    }

    public func copyItemToSupport(at url: URL) throws {
        let sourceURL = url.resolvingSymlinksInPath()
        if isDyldSharedCacheFile(at: sourceURL) {
            for dyldSharedCacheURL in dyldSharedCacheURLs(for: sourceURL) {
                try FileManager.default.copyItem(at: dyldSharedCacheURL, to: targetItem(at: dyldSharedCacheURL))
            }

        } else {
            try FileManager.default.copyItem(at: sourceURL, to: targetItem(at: url))
        }
    }

    public func removeItemFromSupport(at url: URL) throws {
        if isDyldSharedCacheFile(at: url) {
            for dyldSharedCacheURL in dyldSharedCacheURLs(for: url) {
                try FileManager.default.removeItem(at: targetItem(at: dyldSharedCacheURL))
            }
        }
        try FileManager.default.removeItem(at: targetItem(at: url))
    }

    // MARK: - Dyld shared cache supports

    private let dyldSharedCacheSuffixFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        return numberFormatter
    }()

    private func isDyldSharedCacheFile(at url: URL) -> Bool {
        url.lastPathComponent.hasPrefix("dyld_shared_cache")
    }

    private func dyldSharedCacheURLs(for sourceURL: URL) -> [URL] {
        var dyldSharedCacheURLs: [URL] = [sourceURL]
        var currentIndex = 1
        var nextSourceURL: URL? = dyldSharedCacheSuffixFormatter.string(for: currentIndex).map { sourceURL.appendingPathExtension($0) }

        while let dyldSharedCacheURL = nextSourceURL, FileManager.default.fileExists(atPath: dyldSharedCacheURL.path) {
            dyldSharedCacheURLs.append(dyldSharedCacheURL)
            currentIndex += 1
            nextSourceURL = dyldSharedCacheSuffixFormatter.string(for: currentIndex).map { sourceURL.appendingPathExtension($0) }
        }
        return dyldSharedCacheURLs
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
                var isCopied = false
                if isCopyToTemp, !FileManager.default.isWritableFile(atPath: executableURL.path) {
                    try supportManager.copyItemToSupport(at: executableURL)
                    isCopied = true
                }
                let process = Process()
                process.arguments = [isCopied ? supportManager.targetItem(at: executableURL).path : executableURL.path]
                process.executableURL = idaExecutableURL
                process.environment = [
                    "__CFBundleIdentifier": "com.apple.Terminal",
                    "IDAUSR": Self.idaUserDirectoryURL.path,
                ]
                let errorPipe = Pipe()
                process.standardError = errorPipe
                process.terminationHandler = { _ in
                    if isCopied {
                        do {
                            try supportManager.removeItemFromSupport(at: executableURL)
                        } catch {
                            print(error)
                        }
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
