import AppKit
import UIFoundation
import ClassDumperCore
import FZUIKit

public final class ClassDumpApplicationsViewController: ModuleXibViewController {
    @IBOutlet var outlineContainerView: NSView!

    let (scrollView, outlineView): (NSScrollView, ClassDumpApplicationsOutlineView) = ClassDumpApplicationsOutlineView.scrollableOutlineView()

    let classDumpApplicationsController = ClassDumpApplicationsController()

    lazy var outlineViewAdapter = ClassDumpApplicationsOutlineViewAdapter(outlineView: outlineView, classDumpApplicationsController: classDumpApplicationsController)

    public override func viewDidLoad() {
        super.viewDidLoad()
        outlineContainerView.addSubview(withConstraint: scrollView)
        outlineViewAdapter.setup()
        classDumpApplicationsController.delegate = self
    }

    @IBAction func searchApplicationsButtonAction(_ sender: NSButton) {
        outlineViewAdapter.beginUpdate()
        classDumpApplicationsController.searchApplications()
    }
}

extension ClassDumpApplicationsViewController: ClassDumpApplicationsControllerDelegate {
    public func classDumpApplicationsController(_ controller: ClassDumperCore.ClassDumpApplicationsController, didSearchApplications applications: [ClassDumperCore.ClassDumpableApplication]) {
        outlineView.reloadData()
        outlineViewAdapter.endUpdate()
    }
}




