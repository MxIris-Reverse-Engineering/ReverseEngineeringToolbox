//
//  ClassDumpSimulatorViewController.swift
//
//
//  Created by JH on 2024/3/13.
//

import AppKit
import UIFoundation
import ClassDumperCore
import SimulatorManager
import AdvancedCollectionTableView
import FZUIKit
import ApplicationLaunchers
import MenuBuilder
import ClassDump

class ClassDumpSimulatorRuntimeTableView: NSTableView {}
class ClassDumpSimulatorPathTableView: NSTableView {}
class ClassDumpSimulatorView: NSView {}

enum ClassDumpSimulatorRuntimeSection: Identifiable, CaseIterable {
    case main
    var id: Self { self }
}

enum ClassDumpSimulatorPathSection: Identifiable, CaseIterable {
    case main
    var id: Self { self }
}

public class ClassDumpSimulatorViewController: ModuleXibViewController {
    @IBOutlet var runtimesTableView: ClassDumpSimulatorRuntimeTableView!

    @IBOutlet var pathsTableView: ClassDumpSimulatorPathTableView!

    @IBOutlet var filesTableView: ClassDumpFilesTableView!

    private let simulatorController: ClassDumpSimulatorController

    private lazy var runtimesTableViewDataSource: TableViewDiffableDataSource<ClassDumpSimulatorRuntimeSection, SimulatorRumtime> = {
        let cellRegistration = NSTableView.CellRegistration<NSTableCellView, SimulatorRumtime> { cellView, tableColumn, row, item in
            var contentConfiguration = NSListContentConfiguration.plain()
            contentConfiguration.text = item.readableString
            cellView.contentConfiguration = contentConfiguration
        }

        return .init(tableView: runtimesTableView, cellRegistration: cellRegistration)
    }()

    private lazy var pathsTableViewDataSource: TableViewDiffableDataSource<ClassDumpSimulatorPathSection, String> = {
        let cellRegistration = NSTableView.CellRegistration<NSTableCellView, String> { cellView, tableColumn, row, item in
            var contentConfiguration = NSListContentConfiguration.plain()
            contentConfiguration.text = item
            cellView.contentConfiguration = contentConfiguration
        }

        return .init(tableView: pathsTableView, cellRegistration: cellRegistration)
    }()

    private lazy var filesTableViewAdapter = ClassDumpFilesTableViewAdapter(tableView: filesTableView, classDumpController: simulatorController.classDumpFilesController)

    init(simulatorController: ClassDumpSimulatorController) {
        self.simulatorController = simulatorController
        super.init()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        runtimesTableView.do {
            $0.dataSource = runtimesTableViewDataSource
            $0.doubleAction = #selector(runtimesTableViewDoubleAction(_:))
            $0.menu = NSMenu {
                MenuItem("Show in Finder")
                    .onSelect { [weak self] in
                        guard let self else { return }
                        guard runtimesTableView.hasValidClickedRow else { return }
                        guard let runtime = runtimesTableViewDataSource.item(forRow: runtimesTableView.clickedRow) else { return }
                        FinderLauncher(url: runtime.path.filePathURL).run()
                    }
            }
        }

        pathsTableView.do {
            $0.dataSource = pathsTableViewDataSource
            $0.doubleAction = #selector(pathsTableViewDoubleAction(_:))
            $0.menu = NSMenu {
                MenuItem("Show in Finder")
                    .onSelect { [weak self] in
                        guard let self else { return }
                        guard pathsTableView.hasValidClickedRow else { return }
                        guard let path = pathsTableViewDataSource.item(forRow: pathsTableView.clickedRow) else { return }
                        guard let selectedRuntime = runtimesTableViewDataSource.selectedItems.first else { return }
                        FinderLauncher(url: selectedRuntime.runtimeRootPath.filePathURL.appendingPathComponent(path)).run()
                    }
            }
        }

        simulatorController.do {
            $0.delegate = self
            $0.classDumpFilesController.delegate = self
        }

        filesTableViewAdapter.do {
            $0.setup()
        }

        filesTableView.do {
            $0.sizeToFit()
        }

        runtimesTableViewDataSource.do {
            $0.emptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Runtimes")
        }

        pathsTableViewDataSource.do {
            $0.emptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Paths")
        }
    }

    @IBAction func searchRuntimesButtonAction(_ sender: NSButton) {
        simulatorController.searchRuntimes()
    }

    @objc func runtimesTableViewDoubleAction(_ sender: NSTableView) {
        guard let runtime = runtimesTableViewDataSource.item(forRow: sender.clickedRow) else { return }
        simulatorController.selectRuntime(runtime)
    }

    @objc func pathsTableViewDoubleAction(_ sender: NSTableView) {
        guard let path = pathsTableViewDataSource.item(forRow: sender.clickedRow) else { return }
        simulatorController.selectPath(path)
    }
}

extension NSContentUnavailableConfiguration {
    static func emptyContentConfiguration(_ text: String) -> Self {
        var emptyContentConfiguration = NSContentUnavailableConfiguration.empty()
        emptyContentConfiguration.text = text
        emptyContentConfiguration.textProperties.font = .title
        emptyContentConfiguration.textProperties.color = .tertiaryLabelColor
        emptyContentConfiguration.directionalLayoutMargins = .zero
        return emptyContentConfiguration
    }
}

extension ClassDumpSimulatorViewController: ClassDumpFilesControllerDelegate {
    public func classDumpFilesController(_ controller: ClassDumpFilesController, willParseSourceURL url: URL) {
        filesTableViewAdapter.beginUpdate()
    }

    public func classDumpFilesController(_ controller: ClassDumperCore.ClassDumpFilesController, didSelectSourceURL url: URL) {
        filesTableViewAdapter.endUpdate()
        filesTableViewAdapter.reloadData()
    }

    public func classDumpFilesController(_ controller: ClassDumperCore.ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumperCore.ClassDumpableFile) {}

    public func classDumpFilesController(_ controller: ClassDumperCore.ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumperCore.ClassDumpableFile) {}

    public func classDumpFilesControllerWillStartPerform(_ controller: ClassDumperCore.ClassDumpFilesController) {}

    public func classDumpFilesControllerDidCompletePerform(_ controller: ClassDumperCore.ClassDumpFilesController) {}
}

extension ClassDumpSimulatorViewController: ClassDumpSimulatorControllerDelegate {
    public func classDumpSimulatorController(_ controller: ClassDumperCore.ClassDumpSimulatorController, didSearchRuntimes runtimes: [SimulatorRumtime]) {
        var snapshot = runtimesTableViewDataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(runtimes.sorted(by: \.readableString, .ascending), toSection: .main)
        runtimesTableViewDataSource.apply(snapshot, .withoutAnimation)
    }

    public func classDumpSimulatorController(_ controller: ClassDumpSimulatorController, didSelectRuntime runtime: SimulatorRumtime) {
        var snapshot = pathsTableViewDataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(runtime.availablePaths, toSection: .main)
        pathsTableViewDataSource.apply(snapshot, .withoutAnimation)
    }

    public func classDumpSimulatorControllerDidSelectSource(_ controller: ClassDumpSimulatorController) {
//        filesTableView.reloadData()
    }

    public func classDumpSimulatorController(_ controller: ClassDumpSimulatorController, didFailureSelectSourceWithError error: any Error) {
        DispatchQueue.main.async {
            NSAlert(error: error).runModal()
        }
    }
}

extension String: Identifiable {
    public var id: Self { self }
}

extension ClassDumpSimulatorController: Then {}
extension ClassDumpFilesController: Then {}
extension ClassDumpFilesTableViewAdapter: Then {}
