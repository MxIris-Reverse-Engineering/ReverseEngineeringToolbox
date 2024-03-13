import AppKit
import ClassDumperCore
import ApplicationLaunchers

enum ClassDumpFilesTableColumn: String, CaseIterable {
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

class ClassDumpFilesTableView: NSTableView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        tableColumns.forEach(removeTableColumn(_:))
        ClassDumpFilesTableColumn.allCases.forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.width = column.width.width
            tableColumn.minWidth = column.width.minWidth
            tableColumn.maxWidth = column.width.maxWidth
            tableColumn.resizingMask = .autoresizingMask
            addTableColumn(tableColumn)
        }
        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    }
}

class ClassDumpFilesTableViewAdapter: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    unowned let tableView: NSTableView
    unowned let classDumpController: ClassDumpFilesController

    init(tableView: NSTableView, classDumpController: ClassDumpFilesController) {
        self.tableView = tableView
        self.classDumpController = classDumpController
    }

    public func numberOfRows(in tableView: NSTableView) -> Int {
        classDumpController.parsedDumpableFiles.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn, let column = ClassDumpFilesTableColumn(rawValue: tableColumn.identifier.rawValue) else { return nil }
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

    func reloadData() {
        tableView.reloadData()
    }

    func reloadData(forRow row: Int, column: ClassDumpFilesTableColumn) {
        tableView.reloadData(forRowIndexes: [row], columnIndexes: [tableView.column(withIdentifier: column.identifier)])
    }
}
