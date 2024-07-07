import AppKit
import UIFoundation

class ClassDumpFilesTableView: TableView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        style = .inset
        headerView = NSTableHeaderView()
        tableColumns.forEach(removeTableColumn(_:))
        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        allowsColumnReordering = false
        allowsColumnResizing = true
        allowsColumnSelection = false
        [ClassDumpFilesTableColumn.name, .operation, .progress].forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.title = column.title
            tableColumn.width = column.width
            if let minWidth = column.minWidth {
                tableColumn.minWidth = minWidth
            }
            if let maxWidth = column.maxWidth {
                tableColumn.maxWidth = maxWidth
            }
            tableColumn.resizingMask = column.resizingMask
            addTableColumn(tableColumn)
        }
    }
}

enum TableViewSection: Identifiable, CaseIterable {
    case main
    var id: Self { self }
}
