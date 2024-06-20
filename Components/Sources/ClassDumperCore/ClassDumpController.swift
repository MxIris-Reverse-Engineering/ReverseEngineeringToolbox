#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDump

public class ClassDumpController {
    public let configuration: CDClassDumpConfiguration

    public let filesController: ClassDumpFilesController

    public let simulatorController: ClassDumpSimulatorController

    public let applicationsController: ClassDumpApplicationsController

    public init() {
        let configuration = CDClassDumpConfiguration()
        self.configuration = configuration
        self.filesController = ClassDumpFilesController(configuration: configuration)
        self.simulatorController = ClassDumpSimulatorController(configuration: configuration)
        self.applicationsController = ClassDumpApplicationsController()
        ClassDumpFileController.sharedConfiguration.apply(configuration)
    }
}

#endif
