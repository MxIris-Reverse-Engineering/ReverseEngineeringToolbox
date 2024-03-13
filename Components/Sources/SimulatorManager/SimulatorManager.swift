import Foundation
import FoundationToolbox

public final class SimulatorManager {
    public static let shared = SimulatorManager()
    public private(set) var avaliableRuntimes: [SimulatorRumtime] = []
    public private(set) var avaliableImages: [SimulatorImage] = []

    private let fileManager = FileManager.default

    public func searchImages() {
        do {
            let imagesPlistData = try Data(contentsOf: SimulatorPaths.imagesPath.filePathURL)
            let imageList = try PropertyListDecoder().decode(SimulatorImageList.self, from: imagesPlistData)
            let images = imageList.images

            if !images.isEmpty {
                avaliableImages = images
            }
        } catch {
            print(error)
        }
    }

    public func searchRumtimes() {
        searchImages()
        var runtimes: [SimulatorRumtime] = []
        for avaliableImage in avaliableImages {
            if let runtimeURL = avaliableImage.runtimeInfo.bundlePath.relative.removingPercentEncoding.flatMap({ URL(string: $0) }), let runtime = runtime(atPath: runtimeURL.path) {
                runtimes.append(runtime)
            }
        }
        if !runtimes.isEmpty {
            avaliableRuntimes = runtimes
        }
    }

    private func runtime(atPath path: String) -> SimulatorRumtime? {
        let currentRumtimeRootPath = path.box.appendingPathComponent(SimulatorPaths.runtimeRootPath)
        guard fileManager.fileExists(atPath: currentRumtimeRootPath) else { return nil }
        let currentSystemVersionPlistPath = currentRumtimeRootPath.box.appendingPathComponent(SimulatorPaths.systemVersionPath)

        do {
            let systemVersionData = try Data(contentsOf: currentSystemVersionPlistPath.filePathURL)
            let systemVersion = try PropertyListDecoder().decode(SimulatorSystemVersion.self, from: systemVersionData)
            return SimulatorRumtime(systemVersion: systemVersion, path: path, runtimeRootPath: currentRumtimeRootPath)
        } catch {
            print(error)
            return nil
        }
    }
}
