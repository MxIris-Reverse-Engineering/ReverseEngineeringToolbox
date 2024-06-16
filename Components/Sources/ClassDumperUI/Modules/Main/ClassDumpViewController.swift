#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SnapKit
import UIFoundation

public final class ClassDumpViewController: XiblessViewController<NSView> {
    private lazy var tabView = NSTabView()
    
    public private(set) lazy var filesViewController = ClassDumpFilesViewController()

//    public private(set) lazy var dyldViewController = ClassDumpDyldViewController()
    
    public private(set) lazy var simulatorViewController = ClassDumpSimulatorViewController()
    
    public private(set) lazy var applicationsViewController = ClassDumpApplicationsViewController()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tabView)

        tabView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        tabView.tabViewType = .topTabsBezelBorder
        
        let filesItem = NSTabViewItem(viewController: filesViewController).then {
            $0.label = "Files"
        }
        tabView.addTabViewItem(filesItem)
        
//        let dyldItem = NSTabViewItem(viewController: dyldViewController).then {
//            $0.label = "Dyld"
//        }
//        tabView.addTabViewItem(dyldItem)
        
        let simulatorItem = NSTabViewItem(viewController: simulatorViewController).then {
            $0.label = "Simulator"
        }
        tabView.addTabViewItem(simulatorItem)
        
        let applicationsItem = NSTabViewItem(viewController: applicationsViewController).then {
            $0.label = "Applications"
        }
        tabView.addTabViewItem(applicationsItem)
    }
}

#endif
