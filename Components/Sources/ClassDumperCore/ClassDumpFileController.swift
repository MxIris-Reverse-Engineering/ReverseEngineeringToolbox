import Foundation
import ExceptionCatcher

private import ClassDump

public protocol ClassDumpFileControllerDelegate: AnyObject {
    func classDumpFileController(_ controller: ClassDumpFileController, willStartDumpableFile dumpableFile: ClassDumpableFile)
    func classDumpFileController(_ controller: ClassDumpFileController, didCompleteDumpableFile dumpableFile: ClassDumpableFile)
}

public class ClassDumpFileController {
    public static let shared = ClassDumpFileController()
    
    public weak var delegate: ClassDumpFileControllerDelegate?
    
    public init() {}
    
    private let fileManager = FileManager.default
    
    public func performWithAsync(for dumpableFile: ClassDumpableFile, to destinationRootURL: URL) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.perform(for: dumpableFile, to: destinationRootURL)
        }
    }
    
    public func perform(for dumpableFile: ClassDumpableFile, to destinationRootURL: URL) {
        let sourcePath = dumpableFile.executableURL.path
        let destinationPath = destinationRootURL.appendingPathComponent(sourcePath.lastPathComponent.deletingPathExtension).path
        if !fileManager.fileExists(atPath: destinationPath) {
            try? fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true)
        }
        do {
            
            let notifyStart = {
                dumpableFile.state = .loading
                self.delegate?.classDumpFileController(self, willStartDumpableFile: dumpableFile)
            }
            let notifyEnd = {
                dumpableFile.state = .success
                self.delegate?.classDumpFileController(self, didCompleteDumpableFile: dumpableFile)
            }
            
            if Thread.isMainThread {
                notifyStart()
            } else {
                DispatchQueue.main.async(execute: .init(block: notifyStart))
            }
            
            try ExceptionCatcher.catch {
                try CDClassDump.perform(onFile: sourcePath, toFolder: destinationPath, configuration: Self.classDumpConfiguration)
            }
            
            if Thread.isMainThread {
                notifyEnd()
            } else {
                DispatchQueue.main.async(execute: .init(block: notifyEnd))
            }
        } catch {
            print(error.localizedDescription)
            debugPrint(error)
            DispatchQueue.main.async {
                dumpableFile.state = .failure
                self.delegate?.classDumpFileController(self, didCompleteDumpableFile: dumpableFile)
            }
        }
    }
    
    private static let classDumpConfiguration: CDClassDumpConfiguration = {
        let configuration = CDClassDumpConfiguration()
        configuration.shouldStripCtor = true
        configuration.shouldStripDtor = true
        configuration.shouldSortClasses = true
        configuration.shouldSortMethods = true
        configuration.shouldStripOverrides = true
        configuration.shouldStripSynthesized = true
        configuration.shouldShowIvarOffsets = true
        configuration.shouldUseBOOLTypedef = true
        configuration.shouldUseNSIntegerTypedef = true
        configuration.shouldUseNSUIntegerTypedef = true
        configuration.sortedPropertyAttributeTypes = [.threadSafe, .reference, .readwrite, .setter, .getter, .class]
        return configuration
    }()
}
