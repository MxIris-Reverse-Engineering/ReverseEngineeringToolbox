#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UIFoundation

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

#endif
