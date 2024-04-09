#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore

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

#endif
