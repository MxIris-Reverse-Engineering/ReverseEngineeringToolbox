#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UIFoundation

public class ModuleXibViewController: XibViewController {
    public override class var nibBundle: Bundle { .module }
}

#endif
