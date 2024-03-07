#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UIFoundation

public final class ClassDumpDyldViewController: XibViewController {
    public override class var nibBundle: Bundle { .module }
    
}


#endif
