import AppKit
import UIFoundation
import ClassDumperCore
import FZUIKit

public final class ClassDumpApplicationsViewController: ModuleXibViewController {
    @IBOutlet var outlineContainerView: NSView!

    let (scrollView, outlineView): (NSScrollView, ClassDumpApplicationsOutlineView) = ClassDumpApplicationsOutlineView.scrollableOutlineView()

    let applicationsController: ClassDumpApplicationsController

    lazy var outlineViewAdapter = ClassDumpApplicationsOutlineViewAdapter(outlineView: outlineView, classDumpApplicationsController: applicationsController)

    init(applicationsController: ClassDumpApplicationsController) {
        self.applicationsController = applicationsController
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        outlineContainerView.addSubview(withConstraint: scrollView)
        outlineViewAdapter.setup()
        applicationsController.delegate = self
    }

    @IBAction func searchApplicationsButtonAction(_ sender: NSButton) {
        outlineViewAdapter.beginUpdate()
        applicationsController.searchApplications()
    }
}

extension ClassDumpApplicationsViewController: ClassDumpApplicationsControllerDelegate {
    public func classDumpApplicationsController(_ controller: ClassDumperCore.ClassDumpApplicationsController, didSearchApplications applications: [ClassDumperCore.ClassDumpableApplication]) {
        outlineView.reloadData()
        outlineViewAdapter.endUpdate()
    }
}




