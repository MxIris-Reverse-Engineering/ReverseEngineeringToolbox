#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore
import ApplicationLaunchers

enum ClassDumpFileOperationFactory {
    static func setupOperationCellView(_ cellView: ClassDumpOperationCellView, dumpableFile: ClassDumpableFile) {
        cellView.showInFinderOperationButton.box.setAction { [weak dumpableFile] _ in
            guard let dumpableFile else { return }
            FinderLauncher(url: dumpableFile.url).run()
        }
        cellView.openInHopperDisassemblerOperationButton.isEnabled = HopperDisassemblerLauncher.isAvailable
        cellView.openInHopperDisassemblerOperationButton.box.setAction { [weak dumpableFile] _ in
            guard let dumpableFile else { return }
            HopperDisassemblerLauncher(executableURL: dumpableFile.executableURL).run { result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    NSAlert(error: error).runModal()
                }
            }
        }
        cellView.openInIDAOperationButton.isEnabled = IDALauncher.isAvailable
        cellView.openInIDAOperationButton.box.setAction { [weak dumpableFile] _ in
            guard let dumpableFile else { return }
            IDALauncher(executableURL: dumpableFile.executableURL).run { result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    NSAlert(error: error).runModal()
                }
            }
        }
        
        cellView.dumpOperationButton.box.setAction { [weak dumpableFile] _ in
            guard let dumpableFile else { return }
            let openPanel = NSOpenPanel().then {
                $0.canChooseFiles = false
                $0.canChooseDirectories = true
                $0.allowsMultipleSelection = false
            }
            let result = openPanel.runModal()
            guard result == .OK, let url = openPanel.url else { return }
            ClassDumpFileController.shared.performWithAsync(for: dumpableFile, to: url)
        }
        
    }
}

#endif
