#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SnapKit
import UIFoundation

public final class UtilitiesViewController: XiblessViewController<NSView> {
    private lazy var tabView = NSTabView()
    
    private let floatingPointConvertViewController = FloatingPointConvertViewController()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tabView)
        
        tabView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        NSTabViewItem(viewController: floatingPointConvertViewController).do {
            $0.label = "Floating Point Convert"
            tabView.addTabViewItem($0)
        }
    }
}


#endif
