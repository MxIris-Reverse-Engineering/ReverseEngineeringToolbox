#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDump

public class ClassDumpController {
    @SecureCodingDefault
    public var configuration: CDClassDumpConfiguration

    public let filesController: ClassDumpFilesController

    public let simulatorController: ClassDumpSimulatorController

    public let applicationsController: ClassDumpApplicationsController

    public init() {
        let configuration = SecureCodingDefault<CDClassDumpConfiguration>(key: "configuration", suite: .standard, defaultValue: .init(), classes: [NSArray.self, NSString.self])
        self._configuration = configuration
        self.filesController = ClassDumpFilesController(configuration: configuration.wrappedValue)
        self.simulatorController = ClassDumpSimulatorController(configuration: configuration.wrappedValue)
        self.applicationsController = ClassDumpApplicationsController()
        ClassDumpFileController.sharedConfiguration.apply(configuration.wrappedValue)
    }
}


#endif
