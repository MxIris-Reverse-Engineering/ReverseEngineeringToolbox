#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore
import FZUIKit

class ClassDumpApplicationsOutlineViewAdapter: NSObject {
    private unowned let outlineView: ClassDumpApplicationsOutlineView

    private unowned let classDumpApplicationsController: ClassDumpApplicationsController

    public init(outlineView: ClassDumpApplicationsOutlineView, classDumpApplicationsController: ClassDumpApplicationsController) {
        self.outlineView = outlineView
        self.classDumpApplicationsController = classDumpApplicationsController
        super.init()
        outlineView.dataSource = self
        outlineView.delegate = self
    }

    public func setup() {
        setupContextMenu()
        setupEmptyContentConfiguration()
    }

    private let defaultEmptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Dumpable Applications")

    private func setupEmptyContentConfiguration() {
        outlineView.emptyContentConfiguration = defaultEmptyContentConfiguration
    }

    public func beginUpdate() {
        outlineView.emptyContentConfiguration = NSContentUnavailableConfiguration.loading()
    }

    public func endUpdate() {
        if classDumpApplicationsController.applications.isEmpty {
            outlineView.emptyContentConfiguration = defaultEmptyContentConfiguration
        } else {
            outlineView.emptyContentConfiguration = nil
        }
    }
}

extension ClassDumpApplicationsOutlineViewAdapter: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let application = item as? ClassDumpableApplication {
            return application.frameworkDirectories.count + 1
        }

        if let frameworkDirectory = item as? ClassDumpableApplication.FrameworkDirectory {
            return frameworkDirectory.frameworks.count
        }

        if item is ClassDumpableFile {
            return 0
        }

        return classDumpApplicationsController.applications.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let application = item as? ClassDumpableApplication {
            if index == 0 {
                return application.executable
            } else {
                return application.frameworkDirectories[index - 1]
            }
        }

        if let frameworkDirectory = item as? ClassDumpableApplication.FrameworkDirectory {
            return frameworkDirectory.frameworks[index]
        }

        return classDumpApplicationsController.applications[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is ClassDumpableApplication {
            return true
        }

        if let frameworkDirectory = item as? ClassDumpableApplication.FrameworkDirectory {
            return !frameworkDirectory.frameworks.isEmpty
        }

        if item is ClassDumpableFile {
            return false
        }

        return !classDumpApplicationsController.applications.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let outlineColumn = tableColumn.flatMap({ ClassDumpApplicationsOutlineColumn(rawValue: $0.identifier.rawValue) }) else { return nil }
        switch outlineColumn {
        case .name:
            if let item = item as? ClassDumpNameCellView.Configurable {
                let cellView = outlineView.box.makeView(ofClass: ClassDumpNameCellView.self, owner: nil)
                cellView.configure(for: item)
                return cellView
            }
        case .operation:
            if let dumpableFile = item as? ClassDumpableFile {
                let cellView = outlineView.box.makeView(ofClass: ClassDumpOperationCellView.self, owner: nil)
                ClassDumpFileOperationFactory.setupOperationCellView(cellView, dumpableFile: dumpableFile)
                return cellView
            }
        }
        return nil
    }
}

extension ClassDumpApplicationsOutlineViewAdapter: NSMenuItemValidation {
    private func setupContextMenu() {
        outlineView.menu = NSMenu {
            MenuItem("Export File")
                .set(\.target, to: self)
                .set(\.action, to: #selector(exportFileMenuItemAction(_:)))

            MenuItem("Export Executable File (Bundle Only)")
                .set(\.target, to: self)
                .set(\.action, to: #selector(exportExecutableFileMenuItemAction(_:)))
        }
    }

    @objc private func exportFileMenuItemAction(_ sender: NSMenuItem) {
        performExportFileAtClickedRow(asExecutable: false)
    }

    @objc private func exportExecutableFileMenuItemAction(_ sender: NSMenuItem) {
        performExportFileAtClickedRow(asExecutable: true)
    }

    private func performExportFileAtClickedRow(asExecutable: Bool) {
        guard outlineView.hasValidClickedRow else { return }
        guard let dumpableFile = outlineView.itemAtClickedRow as? ClassDumpableFile else { return }
        ClassDumpableFileExporter.export(dumpableFile, asExecutable: asExecutable)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(exportFileMenuItemAction(_:)):
            return outlineView.box.clickedRowItemConform(of: ClassDumpableFile.self)
        case #selector(exportExecutableFileMenuItemAction(_:)):
            guard let dumpableFile = outlineView.itemAtClickedRow as? ClassDumpableFile else { return false }
            return dumpableFile.type == .framework
        default:
            return true
        }
    }
}
#endif
