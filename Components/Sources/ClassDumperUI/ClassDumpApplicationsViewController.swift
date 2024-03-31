//
//  ClassDumpApplicationsViewController.swift
//
//
//  Created by JH on 2024/3/29.
//

import AppKit
import UIFoundation
import ClassDumperCore
import FZUIKit

enum ClassDumpApplicationsOutlineColumn: String, CaseIterable {
    case name
    ///    case info
    case operation

    var identifier: NSUserInterfaceItemIdentifier {
        .init(rawValue: rawValue)
    }

    var title: String {
        switch self {
        case .name:
            "Name"
        case .operation:
            "Operation"
        }
    }

    var width: CGFloat {
        switch self {
        case .name:
            400
        case .operation:
            300
        }
    }
}

class ClassDumpApplicationsOutlineView: OutlineView {
    override func setup() {
        super.setup()
        headerView = NSTableHeaderView()
        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        allowsColumnReordering = false
        allowsColumnResizing = true
        allowsColumnSelection = false

        for column in ClassDumpApplicationsOutlineColumn.allCases {
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.title = column.title
            tableColumn.width = column.width
//            if let minWidth = column.minWidth {
//                tableColumn.minWidth = minWidth
//            }
//            if let maxWidth = column.maxWidth {
//                tableColumn.maxWidth = maxWidth
//            }
//            tableColumn.resizingMask = column.resizingMask
            addTableColumn(tableColumn)
        }
    }
}

public final class ClassDumpApplicationsViewController: ModuleXibViewController {
    @IBOutlet var outlineContainerView: NSView!

    let (scrollView, outlineView): (NSScrollView, ClassDumpApplicationsOutlineView) = ClassDumpApplicationsOutlineView.scrollableOutlineView()

    let classDumpApplicationsController = ClassDumpApplicationsController()

    lazy var outlineViewAdapter = ClassDumpApplicationsOutlineViewAdapter(outlineView: outlineView, classDumpApplicationsController: classDumpApplicationsController)

    public override func viewDidLoad() {
        super.viewDidLoad()
        outlineContainerView.addSubview(withConstraint: scrollView)

        outlineViewAdapter.setup()
        classDumpApplicationsController.delegate = self
    }

    @IBAction func searchApplicationsButtonAction(_ sender: NSButton) {
        outlineViewAdapter.beginUpdate()
        classDumpApplicationsController.searchApplications()
    }
}

extension ClassDumpApplicationsViewController: ClassDumpApplicationsControllerDelegate {
    public func classDumpApplicationsController(_ controller: ClassDumperCore.ClassDumpApplicationsController, didSearchApplications applications: [ClassDumperCore.ClassDumpableApplication]) {
        outlineView.reloadData()
        outlineViewAdapter.endUpdate()
    }
}

class ClassDumpApplicationsOutlineViewAdapter: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    private unowned let outlineView: ClassDumpApplicationsOutlineView

    private unowned let classDumpApplicationsController: ClassDumpApplicationsController

    init(outlineView: ClassDumpApplicationsOutlineView, classDumpApplicationsController: ClassDumpApplicationsController) {
        self.outlineView = outlineView
        self.classDumpApplicationsController = classDumpApplicationsController
        super.init()
        outlineView.dataSource = self
        outlineView.delegate = self
    }

    func setup() {
        outlineView.emptyContentConfiguration = defaultEmptyContentConfiguration
    }

    private let defaultEmptyContentConfiguration = NSContentUnavailableConfiguration.emptyContentConfiguration("No Available Dumpable Applications")

    func beginUpdate() {
        outlineView.emptyContentConfiguration = NSContentUnavailableConfiguration.loading()
    }

    func endUpdate() {
        if classDumpApplicationsController.applications.isEmpty {
            outlineView.emptyContentConfiguration = defaultEmptyContentConfiguration
        } else {
            outlineView.emptyContentConfiguration = nil
        }
    }

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

extension ClassDumpableFileType {
    public var icon: NSImage? {
        switch self {
        case .executable,
             .dylib:
            "ExecutableBinaryIcon".image
        case .framework:
            "FrameworkIcon".image
        }
    }
}
