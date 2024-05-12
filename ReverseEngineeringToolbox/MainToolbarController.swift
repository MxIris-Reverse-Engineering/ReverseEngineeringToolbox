#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

class MainToolbarController: NSObject, NSToolbarDelegate {
    let toolbar = NSToolbar()

    override init() {
        super.init()
        toolbar.delegate = self
    }
}

#endif
