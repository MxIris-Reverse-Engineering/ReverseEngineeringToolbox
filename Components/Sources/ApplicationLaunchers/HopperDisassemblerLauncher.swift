//
//  HopperDisassemblerLauncher.swift
//  ClassDumper
//
//  Created by JH on 2024/2/25.
//

import AppKit

public struct HopperDisassemblerLauncher {
    public enum Error: Swift.Error {
        case processError(String)
        case openApplicationError(Swift.Error)
    }

    public let executableURL: URL

    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    public static var isAvailable: Bool {
        FileManager.default.fileExists(atPath: "/usr/local/bin/hopperv4")
    }
    
    private static let commandLineExecutableURL = URL(fileURLWithPath: "/usr/local/bin/hopperv4")

    private static let bundleIdentifier = "com.cryptic-apps.hopper-web-4"

    public func run(completion: @escaping (_ result: Result<Void, Swift.Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                let process = Process()
                process.arguments = ["-e", executableURL.path]
                process.executableURL = Self.commandLineExecutableURL
                process.environment = [
                    "__CFBundleIdentifier": "com.apple.Terminal",
                ]
                let errorPipe = Pipe()
                process.standardError = errorPipe

                try process.run()
                process.waitUntilExit()

                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
                    throw Error.processError(error)
                }
                
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
