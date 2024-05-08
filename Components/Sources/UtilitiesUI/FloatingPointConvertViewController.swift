#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UtilitiesCore

class FloatingPointConvertViewController: NSViewController {
    let convertController = FloatingPointConvertController()

    @IBOutlet var segmentedControl: NSSegmentedControl!
    @IBOutlet var decimalTextField: NSTextField!
    @IBOutlet var hexadecimalTextField: NSTextField!
    @IBOutlet var binaryTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

#endif
