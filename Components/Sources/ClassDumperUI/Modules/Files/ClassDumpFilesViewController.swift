//
//  ClassDumpViewController.swift
//  ClassDumper
//
//  Created by JH on 2024/2/23.
//

import AppKit
import SnapKit
import SFSymbol
import UIFoundation
import UIFoundationToolbox
import FrameworkToolbox
import FoundationToolbox
import UniformTypeIdentifiers
import ClassDumperCore
import ApplicationLaunchers
import ClassDump

public class ClassDumpFilesViewController: ModuleXibViewController {
    @MagicViewLoading @IBOutlet var selectSourceButton: NSButton
    @MagicViewLoading @IBOutlet var performButton: NSButton
    @MagicViewLoading @IBOutlet var showInFinderButton: NSButton
    @MagicViewLoading @IBOutlet var isDirectoryCheckbox: NSButton
    @MagicViewLoading @IBOutlet var autoSelectDestinationCheckbox: NSButton
    @MagicViewLoading @IBOutlet var sourcePathTextField: NSTextField
    @MagicViewLoading @IBOutlet var totalProgressIndicator: NSProgressIndicator
    @MagicViewLoading @IBOutlet var tableView: ClassDumpFilesTableView
    
    let filesController: ClassDumpFilesController
    
    lazy var tableViewAdapter = ClassDumpFilesTableViewAdapter(tableView: tableView, classDumpController: filesController)

    init(filesController: ClassDumpFilesController) {
        self.filesController = filesController
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        observeClassDumpService()
        tableViewAdapter.setup()
        filesController.delegate = self
    }
    
    private func observeClassDumpService() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleClassDumpService(_:)), name: ClassDumpService.performClassDumpNotification, object: nil)
    }

    @objc func handleClassDumpService(_ notification: Notification) {
        if let fileURL = notification.userInfo?[ClassDumpService.classDumpFileURLKey] as? URL {
            filesController.selectSourceURL(fileURL)
        }
    }

    @IBAction func selectSourceButtonAction(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.unixExecutable, .framework]
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.treatsFilePackagesAsDirectories = true
        let response = openPanel.runModal()
        guard response == .OK, let url = openPanel.url else { return }
        filesController.selectSourceURL(url)
    }

    @IBAction func performButtonAction(_ sender: NSButton) {
        if autoSelectDestinationCheckbox.state == .on, let currentSourceURL = filesController.currentSourceURL {
            // source: /A/B/Frameworks
            // destination: /A/B/FrameworksDumpHeaders
            let destinationURL = currentSourceURL.deletingLastPathComponent().appendingPathComponent("\(currentSourceURL.lastPathComponent)_DumpHeaders")
            filesController.perform(for: destinationURL)
        } else {
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = [.directory]
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.canCreateDirectories = true
            let response = openPanel.runModal()
            guard response == .OK, let url = openPanel.url else { return }
            filesController.perform(for: url)
        }
    }

    @IBAction func showInFinderButtonAction(_ sender: NSButton) {
        if let selectedSourceURL = filesController.currentSourceURL {
            FinderLauncher(url: selectedSourceURL).run()
        }
    }
}

extension ClassDumpFilesViewController: ClassDumpFilesControllerDelegate {
    public func classDumpFilesController(_ controller: ClassDumpFilesController, willParseSourceURL url: URL) {}

    public func classDumpFilesController(_ controller: ClassDumpFilesController, didSelectSourceURL url: URL) {
        sourcePathTextField.stringValue = url.path
        showInFinderButton.isEnabled = true
        performButton.isEnabled = true
        isDirectoryCheckbox.state = filesController.isDirectory ? .on : .off
        tableViewAdapter.reloadData()
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, willStartDumpableFile dumpableFile: ClassDumpableFile) {
        tableViewAdapter.reconfigureItem(dumpableFile)
    }

    public func classDumpFilesController(_ controller: ClassDumpFilesController, didCompleteDumpableFile dumpableFile: ClassDumpableFile) {
        let progressValue = filesController.completedDumpableFiles.count.double / filesController.parsedDumpableFiles.count.double
        totalProgressIndicator.doubleValue = progressValue
        totalProgressIndicator.stopAnimation(nil)
        tableViewAdapter.reconfigureItem(dumpableFile)
    }

    public func classDumpFilesControllerWillStartPerform(_ controller: ClassDumpFilesController) {
        totalProgressIndicator.doubleValue = 0
        totalProgressIndicator.isIndeterminate = filesController.parsedDumpableFiles.count == 1
        totalProgressIndicator.startAnimation(nil)
        performButton.isEnabled = false
    }

    public func classDumpFilesControllerDidCompletePerform(_ controller: ClassDumpFilesController) {
        performButton.isEnabled = true
    }
}


