#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

enum ClassDumpFilesTableColumn: String, CaseIterable {
    case name = "Name"
    case type = "Type"
    case operation = "Operation"
    case progress = "Progress"
    var identifier: NSUserInterfaceItemIdentifier { .init(rawValue: rawValue) }

    var width: CGFloat {
        switch self {
        case .name:
            400
        case .type:
            30
        case .operation:
            200
        case .progress:
            30
        }
    }
    
    var minWidth: CGFloat? {
        switch self {
        case .name:
            200
        case .type:
            30
        case .operation:
            200
        case .progress:
            30
        }
    }
    
    var maxWidth: CGFloat? {
        switch self {
        case .name:
            nil
        case .type:
            30
        case .operation:
            400
        case .progress:
            30
        }
    }
    
    var title: String {
        if self != .progress {
            return rawValue
        } else {
            return ""
        }
    }
    
    var resizingMask: NSTableColumn.ResizingOptions {
        if self == .name {
            return [.autoresizingMask, .userResizingMask]
        } else {
            return [.autoresizingMask]
        }
    }
}

#endif
