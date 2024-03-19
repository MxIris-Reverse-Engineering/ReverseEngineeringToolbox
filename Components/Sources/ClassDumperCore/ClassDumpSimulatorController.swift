import Foundation
import SimulatorManager

public protocol ClassDumpSimulatorControllerDelegate: AnyObject {
    func classDumpSimulatorController(_ controller: ClassDumpSimulatorController, didSearchRuntimes runtimes: [SimulatorRumtime])
    func classDumpSimulatorController(_ controller: ClassDumpSimulatorController, didSelectRuntime runtime: SimulatorRumtime)
    func classDumpSimulatorControllerDidSelectSource(_ controller: ClassDumpSimulatorController)
    func classDumpSimulatorController(_ controller: ClassDumpSimulatorController, didFailureSelectSourceWithError error: Error)
}


public class ClassDumpSimulatorController {
    
    public weak var delegate: ClassDumpSimulatorControllerDelegate?
    
    public let simulatorManager = SimulatorManager.shared
    
    public let classDumpFilesController = ClassDumpFilesController()

    public private(set) var selectedRuntime: SimulatorRumtime?
    
    public private(set) var selectedPath: String?
    
    public init() {}
    
    
    public func searchRuntimes() {
        simulatorManager.searchRumtimes()
        delegate?.classDumpSimulatorController(self, didSearchRuntimes: simulatorManager.avaliableRuntimes)
    }
    
    public func selectRuntime(_ runtime: SimulatorRumtime) {
        selectedRuntime = runtime
        delegate?.classDumpSimulatorController(self, didSelectRuntime: runtime)
    }
    
    public func selectPath(_ path: String) {
        selectedPath = path
        guard let selectedRuntime else { return }
        selectSource(selectedRuntime.runtimeRootPath.filePathURL.appendingPathComponent(path))
    }
    
    
    private func selectSource(_ sourceURL: URL) {
        print(sourceURL.path)
        do {
            try classDumpFilesController.selectSourceURL(sourceURL)
            delegate?.classDumpSimulatorControllerDidSelectSource(self)
        } catch {
            delegate?.classDumpSimulatorController(self, didFailureSelectSourceWithError: error)
        }
    }
}
