#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SnapKit
import UIFoundation

public final class ClassDumpViewController: XiblessViewController<NSView> {
    private lazy var tabView = NSTabView()
    
    public private(set) lazy var filesViewController = ClassDumpFilesViewController()

    public private(set) lazy var dyldViewController = ClassDumpDyldViewController()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tabView)

        tabView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }

        tabView.tabViewType = .topTabsBezelBorder
        let filesItem = NSTabViewItem(viewController: filesViewController)
        filesItem.label = "Files"
        tabView.addTabViewItem(filesItem)
        let dyldItem = NSTabViewItem(viewController: dyldViewController)
        dyldItem.label = "Dyld"
        tabView.addTabViewItem(dyldItem)
    }
}

#endif
