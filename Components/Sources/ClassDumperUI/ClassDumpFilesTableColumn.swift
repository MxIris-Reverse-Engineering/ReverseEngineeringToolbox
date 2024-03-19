#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

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

#endif
