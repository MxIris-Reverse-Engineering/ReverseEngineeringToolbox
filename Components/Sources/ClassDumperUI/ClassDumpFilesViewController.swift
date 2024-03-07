//
//  ClassDumpViewController.swift
//  ClassDumper
//
//  Created by JH on 2024/2/23.
//

import AppKit
import SFSymbol
import UIFoundation
import UIFoundationToolbox
import FrameworkToolbox
import FoundationToolbox
import UniformTypeIdentifiers
import ClassDumperCore
import ApplicationLaunchers

public class ClassDumpFilesViewController: XibViewController {
    public override class var nibBundle: Bundle { .module }

    enum Column: String, CaseIterable {
        case name = "Name"
        case type = "Type"
        case operation = "Operation"
        case progress = "Progress"
        var identifier: NSUserInterfaceItemIdentifier { .init(rawValue: rawValue) }

        var width: (width: CGFloat, minWidth: CGFloat, maxWidth: CGFloat) {
            switch self {
            case .name:
                (200, 200, 200)
            case .type:
                (30, 30, 30)
            case .operation:
                (1000, 100, 1000)
            case .progress:
                (30, 30, 30)
            }
        }
    }

    @IBOutlet var selectSourceButton: NSButton!
    @IBOutlet var performButton: NSButton!
    @IBOutlet var showInFinderButton: NSButton!
    @IBOutlet var isDirectoryCheckbox: NSButton!
    @IBOutlet var autoSelectDestinationCheckbox: NSButton!
    @IBOutlet var sourcePathTextField: NSTextField!
    @IBOutlet var totalProgressIndicator: NSProgressIndicator!
    @IBOutlet var tableView: NSTableView!

    let classDumpController = ClassDumpFilesController()

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableColumns.forEach(tableView.removeTableColumn(_:))
        Column.allCases.forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.width = column.width.width
            tableColumn.minWidth = column.width.minWidth
            tableColumn.maxWidth = column.width.maxWidth
            tableColumn.resizingMask = .autoresizingMask
            tableView.addTableColumn(tableColumn)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        classDumpController.delegate = self
    }

    @IBAction func selectSourceButtonAction(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.unixExecutable, .framework]
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        let response = openPanel.runModal()
        guard response == .OK, let url = openPanel.url else { return }
        do {
            try classDumpController.selectSourceURL(url)
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @IBAction func performButtonAction(_ sender: NSButton) {
        if autoSelectDestinationCheckbox.state == .on, let currentSourceURL = classDumpController.currentSourceURL {
            // source: /A/B/Frameworks
            // destination: /A/B/FrameworksDumpHeaders
            let destinationURL = currentSourceURL.deletingLastPathComponent().appendingPathComponent("\(currentSourceURL.lastPathComponent)DumpHeaders")
            classDumpController.perform(for: destinationURL)
        } else {
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = [.directory]
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.canCreateDirectories = true
            let response = openPanel.runModal()
            guard response == .OK, let url = openPanel.url else { return }
            classDumpController.perform(for: url)
        }
    }

    @IBAction func showInFinderButtonAction(_ sender: NSButton) {
        classDumpController.showInFinder()
    }
}

extension ClassDumpFilesViewController: NSTableViewDataSource, NSTableViewDelegate {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        classDumpController.parsedDumpableFiles.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn, let column = Column(rawValue: tableColumn.identifier.rawValue) else { return nil }
        let dumpableFile = classDumpController.parsedDumpableFiles[row]
        switch column {
        case .name:
            let cellView = tableView.box.makeView(ofClass: ClassDumpNameCellView.self, owner: nil)
            cellView.configure(for: dumpableFile)
            return cellView
        case .type:
            let cellView = tableView.box.makeView(ofClass: ClassDumpTypeCellView.self, owner: nil)
            cellView.textField?.stringValue = dumpableFile.executableURL.path
            return cellView
        case .operation:
            let cellView = tableView.box.makeView(ofClass: ClassDumpOperationCellView.self, owner: nil)
            cellView.showInFinderOperationButton.box.setAction { [weak dumpableFile] _ in
                guard let dumpableFile else { return }
                FinderLauncher(url: dumpableFile.url).run()
            }
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
            return cellView
        case .progress:
            let cellView = tableView.box.makeView(ofClass: ClassDumpProgressCellView.self, owner: nil)
            cellView.state = dumpableFile.state
            return cellView
        }
    }
}

extension ClassDumpFilesViewController: ClassDumpFilesControllerDelegate {
    public func classDumpFilesController(_ controller: ClassDumpFilesController, didSelectSourceURL url: URL) {
        sourcePathTextField.stringValue = url.path
        showInFinderButton.isEnabled = true
        performButton.isEnabled = true
        isDirectoryCheckbox.state = (classDumpController.currentSourceFileWrapper?.isDirectory ?? false) ? .on : .off
        tableView.reloadData()
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumpableFile, atIndex index: Int) {
        tableView.reloadData(forRowIndexes: [index], columnIndexes: [tableView.column(withIdentifier: Column.progress.identifier)])
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumpableFile, atIndex index: Int) {
        let progressValue = classDumpController.completedDumpableFiles.count.double / classDumpController.parsedDumpableFiles.count.double
        totalProgressIndicator.doubleValue = progressValue
        tableView.reloadData(forRowIndexes: [index], columnIndexes: [tableView.column(withIdentifier: Column.progress.identifier)])
    }

    public func classDumpFilesControllerWillStartPerform(_ controller: ClassDumpFilesController) {
        totalProgressIndicator.doubleValue = 0
        totalProgressIndicator.isIndeterminate = classDumpController.parsedDumpableFiles.count == 1
        totalProgressIndicator.startAnimation(nil)
        performButton.isEnabled = false
    }

    public func classDumpFilesControllerDidCompletePerform(_ controller: ClassDumpFilesController) {
        performButton.isEnabled = true
    }
}

extension ClassDumpingState {
    var image: NSImage? {
        switch self {
        case .ready:
            SFSymbol(systemName: .plusCircle).nsImage
        case .loading:
            nil
        case .failure:
            SFSymbol(systemName: .xmarkCircle).nsImage
        case .success:
            SFSymbol(systemName: .checkmarkCircle).nsImage
        }
    }

    var color: NSColor? {
        switch self {
        case .ready:
            .systemOrange
        case .loading:
            nil
        case .failure:
            .systemRed
        case .success:
            .systemGreen
        }
    }
}
