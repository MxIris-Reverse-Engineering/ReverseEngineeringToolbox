#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore

enum ClassDumpableFileExporter {
    static func export(_ dumpableFile: ClassDumpableFile, asExecutable: Bool) {
        let savePanel = NSSavePanel().then {
            $0.allowedContentTypes = [dumpableFile.contentType(asExecutable: asExecutable)]
            $0.canCreateDirectories = true
            $0.treatsFilePackagesAsDirectories = true
            $0.nameFieldStringValue = dumpableFile.filename
        }
        let result = savePanel.runModal()
        guard result == .OK, let url = savePanel.url else {
            return
        }

        do {
            if asExecutable {
                try dumpableFile.writeExecutable(to: url)
            } else {
                try dumpableFile.write(to: url)
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

#endif
