import AppKit

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
        style = .inset
        tableColumns.forEach(removeTableColumn(_:))
        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        ClassDumpFilesTableColumn.allCases.forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.width = column.width.width
            tableColumn.minWidth = column.width.minWidth
            tableColumn.maxWidth = column.width.maxWidth
            tableColumn.resizingMask = .autoresizingMask
            addTableColumn(tableColumn)
        }
    }
}

enum TableViewSection: Identifiable, CaseIterable {
    case main
    var id: Self { self }
}
