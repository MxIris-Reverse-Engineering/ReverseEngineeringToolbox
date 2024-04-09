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

public class ClassDumpFilesViewController: ModuleXibViewController {
    @IBOutlet var selectSourceButton: NSButton!
    @IBOutlet var performButton: NSButton!
    @IBOutlet var showInFinderButton: NSButton!
    @IBOutlet var isDirectoryCheckbox: NSButton!
    @IBOutlet var autoSelectDestinationCheckbox: NSButton!
    @IBOutlet var sourcePathTextField: NSTextField!
    @IBOutlet var totalProgressIndicator: NSProgressIndicator!
    @IBOutlet var tableView: ClassDumpFilesTableView!
    let classDumpController = ClassDumpFilesController()
    lazy var tableViewAdapter = ClassDumpFilesTableViewAdapter(tableView: tableView, classDumpController: classDumpController)

    public override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = tableViewAdapter
//        tableView.delegate = tableViewAdapter
        tableViewAdapter.setup()
        classDumpController.delegate = self
    }

    @IBAction func selectSourceButtonAction(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.unixExecutable, .framework]
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.treatsFilePackagesAsDirectories = true
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
        if let selectedSourceURL = classDumpController.currentSourceURL {
            FinderLauncher(url: selectedSourceURL).run()
        }
    }
}

extension ClassDumpFilesViewController: ClassDumpFilesControllerDelegate {
    public func classDumpFilesController(_ controller: ClassDumpFilesController, willParseSourceURL url: URL) {
        
    }
    public func classDumpFilesController(_ controller: ClassDumpFilesController, didSelectSourceURL url: URL) {
        sourcePathTextField.stringValue = url.path
        showInFinderButton.isEnabled = true
        performButton.isEnabled = true
        isDirectoryCheckbox.state = (classDumpController.currentSourceFileWrapper?.isDirectory ?? false) ? .on : .off
        tableViewAdapter.reloadData()
        
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumpableFile) {
//        tableViewAdapter.reloadData(forRow: index, column: .progress)
        tableViewAdapter.reconfigureItem(dumpableFile)
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumpableFile) {
        let progressValue = classDumpController.completedDumpableFiles.count.double / classDumpController.parsedDumpableFiles.count.double
        totalProgressIndicator.doubleValue = progressValue
//        tableViewAdapter.reloadData(forRow: index, column: .progress)
        tableViewAdapter.reconfigureItem(dumpableFile)
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
