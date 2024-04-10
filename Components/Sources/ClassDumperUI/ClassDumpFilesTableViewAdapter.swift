#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore
import ApplicationLaunchers
import FZUIKit
import AdvancedCollectionTableView



class ClassDumpFilesTableViewAdapter {
    private unowned let tableView: NSTableView
    private unowned let classDumpController: ClassDumpFilesController
    private let dataSource: TableViewDiffableDataSource<TableViewSection, ClassDumpableFile>
    init(tableView: NSTableView, classDumpController: ClassDumpFilesController) {
        self.tableView = tableView
        self.classDumpController = classDumpController

        let nameCellRegistration = NSTableView.CellRegistration<ClassDumpNameCellView, ClassDumpableFile>(columnIdentifiers: [ClassDumpFilesTableColumn.name.identifier]) { cellView, tableColumn, row, dumpableFile in
            cellView.configure(for: dumpableFile)
        }

        let operationCellRegistration = NSTableView.CellRegistration<ClassDumpOperationCellView, ClassDumpableFile>(columnIdentifiers: [ClassDumpFilesTableColumn.operation.identifier]) { cellView, tableColumn, row, dumpableFile in
            ClassDumpFileOperationFactory.setupOperationCellView(cellView, dumpableFile: dumpableFile)
        }
        let progressCellRegistration = NSTableView.CellRegistration<ClassDumpProgressCellView, ClassDumpableFile>(columnIdentifiers: [ClassDumpFilesTableColumn.progress.identifier]) { cellView, tableColumn, row, dumpableFile in
            cellView.state = dumpableFile.state
        }
        self.dataSource = .init(tableView: tableView, cellRegistrations: [nameCellRegistration, operationCellRegistration, progressCellRegistration])
    }

    func setup() {
        setupDataSource()
        setupMenu()
    }

    func setupDataSource() {
        tableView.dataSource = dataSource
        dataSource.emptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Dumpable Files")
    }

    func setupMenu() {
        dataSource.menuProvider = { dumpableFiles -> NSMenu? in
            guard let dumpableFile = dumpableFiles.first else { return nil }
            return NSMenu {
                MenuItem("Copy Path")
                    .onSelect {
                        NSPasteboard.general.string = dumpableFile.url.path
                    }
                MenuItem("Copy Executable Path")
                    .onSelect {
                        NSPasteboard.general.string = dumpableFile.executableURL.path
                    }
            }
        }
    }

    func beginUpdate() {
        dataSource.apply(dataSource.emptySnapshot(), .withoutAnimation)
        dataSource.emptyContentConfiguration = NSContentUnavailableConfiguration.loading()
    }

    func endUpdate() {}

    func reloadData() {
        var snapshot = dataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(classDumpController.parsedDumpableFiles, toSection: .main)
        dataSource.apply(snapshot, .withoutAnimation)
        dataSource.emptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Dumpable Files")
    }

    func reloadItem(_ item: ClassDumpableFile) {
        dataSource.reloadItems([item])
    }

    func reconfigureItem(_ item: ClassDumpableFile) {
        dataSource.reconfigureItems([item])
    }
}

#endif
