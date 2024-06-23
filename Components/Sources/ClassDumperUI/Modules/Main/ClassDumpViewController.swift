#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SnapKit
import UIFoundation
import DSFToolbar
import ClassDumperCore
import SFSymbol
import ClassDump

public final class ClassDumpViewController: XiblessViewController<NSView> {
    private lazy var tabView = NSTabView()

    public let classDumpController = ClassDumpController()

    public private(set) lazy var filesViewController = ClassDumpFilesViewController(filesController: classDumpController.filesController)

//    public private(set) lazy var dyldViewController = ClassDumpDyldViewController()

    public private(set) lazy var simulatorViewController = ClassDumpSimulatorViewController(simulatorController: classDumpController.simulatorController)

    public private(set) lazy var applicationsViewController = ClassDumpApplicationsViewController(applicationsController: classDumpController.applicationsController)

    private var toolbar: DSFToolbar?

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

        toolbar = DSFToolbar("\(ClassDumpViewController.self) Toolbar") {
            DSFToolbar.FixedSpace()
            DSFToolbar.Button(.Toolbar.configuration)
                .bezelStyle(.toolbar)
                .image(SFSymbol(systemName: .ellipsisCurlybraces).nsImage)
                .action { [unowned self] button in
                    ClassDumpConfigurationViewController(configuration: classDumpController.configuration).then {
                        self.present($0, asPopoverRelativeTo: button.bounds, of: button, preferredEdge: .maxY, behavior: .transient)
                    }
                }
        }.displayMode(.iconOnly)
    }

    public override func viewDidAppear() {
        super.viewDidAppear()

        toolbar?.attachedWindow = view.window
    }
}

class ClassDumpConfigurationViewController: XiblessViewController<View> {
    let (scrollView, tableView) = SingleColumnTableView.scrollableTableView()

    let configuration: CDClassDumpConfiguration

    lazy var contentStackView = VStackView(alignment: .left, spacing: 10) {
        Button(checkbox: "Should Process Recursively") { [unowned self] in
            configuration.shouldProcessRecursively = $0.boolValue
        }
        .state(configuration.shouldProcessRecursively)

        Button(checkbox: "Should Sort Methods") { [unowned self] in
            configuration.shouldSortMethods = $0.boolValue
        }
        .state(configuration.shouldSortMethods)

        Button(checkbox: "Should Show Ivar Offsets") { [unowned self] in
            configuration.shouldShowIvarOffsets = $0.boolValue
        }
        .state(configuration.shouldShowIvarOffsets)

        Button(checkbox: "Should Show Method Addresses") { [unowned self] in
            configuration.shouldShowMethodAddresses = $0.boolValue
        }
        .state(configuration.shouldShowMethodAddresses)

        Button(checkbox: "Should Strip Ctor") { [unowned self] in
            configuration.shouldStripCtor = $0.boolValue
        }
        .state(configuration.shouldStripCtor)

        Button(checkbox: "Should Strip Dtor") { [unowned self] in
            configuration.shouldStripDtor = $0.boolValue
        }
        .state(configuration.shouldStripDtor)

        Button(checkbox: "Should Strip Overrides") { [unowned self] in
            configuration.shouldStripOverrides = $0.boolValue
        }
        .state(configuration.shouldStripOverrides)

        Button(checkbox: "Should Strip Synthesized") { [unowned self] in
            configuration.shouldStripSynthesized = $0.boolValue
        }
        .state(configuration.shouldStripSynthesized)

        Button(checkbox: "Should Generate Empty Implementation File") { [unowned self] in
            configuration.shouldGenerateEmptyImplementationFile = $0.boolValue
        }
        .state(configuration.shouldGenerateEmptyImplementationFile)

        Button(checkbox: "Should Use BOOL Typedef") { [unowned self] in
            configuration.shouldUseBOOLTypedef = $0.boolValue
        }
        .state(configuration.shouldUseBOOLTypedef)

        Button(checkbox: "Should Use NSInteger Typedef") { [unowned self] in
            configuration.shouldUseNSIntegerTypedef = $0.boolValue
        }
        .state(configuration.shouldUseNSIntegerTypedef)

        Button(checkbox: "Should Use NSUInteger Typedef") { [unowned self] in
            configuration.shouldUseNSUIntegerTypedef = $0.boolValue
        }
        .state(configuration.shouldUseNSUIntegerTypedef)
    }

    init(configuration: CDClassDumpConfiguration) {
        self.configuration = configuration
        super.init(viewGenerator: View())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
}

extension String {
    enum Toolbar {
        static let configuration = "configuration"
    }
}

extension NSButton {
    var boolValue: Bool {
        state == .on
    }

    func state(_ boolValue: Bool) -> Self {
        state = boolValue ? .on : .off
        return self
    }
}

#endif
