#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import ClassDumperCore
import SFSymbol

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


#endif
