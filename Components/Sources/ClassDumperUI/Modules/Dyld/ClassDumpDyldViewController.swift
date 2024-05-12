#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UIFoundation
import ClassDumperCore
import AdvancedCollectionTableView
import FZUIKit
import ApplicationLaunchers
import MenuBuilder

public final class ClassDumpDyldViewController: ModuleXibViewController {
    private typealias DataSource = TableViewDiffableDataSource<TableViewSection, ClassDumpableImage>

    private typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, ClassDumpableImage>

    @IBOutlet var systemVersionValueLabel: NSTextField!

    @IBOutlet var searchImagesButton: NSButton!

    @IBOutlet var performDumpAllImageButton: NSButton!

    @IBOutlet var imagesTableView: NSTableView!

    @IBOutlet var showInFinderButton: NSButton!

    @IBOutlet var openInHopperButton: NSButton!

    @IBOutlet var openInIDAButton: NSButton!

    private let classDumpDyldController = ClassDumpDyldController()

    private lazy var imagesTableViewDataSource: DataSource = {
        let cellRegistration = CellRegistration { cellView, tableColumn, row, item in
            var contentConfiguration = NSListContentConfiguration.plain()
            contentConfiguration.text = item.path
            cellView.contentConfiguration = contentConfiguration
        }
        return DataSource(tableView: imagesTableView, cellRegistration: cellRegistration)
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        systemVersionValueLabel.stringValue = ProcessInfo.processInfo.operatingSystemVersionString

        classDumpDyldController.delegate = self
        showInFinderButton.image = .finderAppIcon(forSize: 20)
        openInHopperButton.image = .hopperAppIcon(forSize: 20)
        openInIDAButton.image = .idaAppIcon(forSize: 20)
        
        imagesTableView.do {
            $0.dataSource = imagesTableViewDataSource
            $0.menu = NSMenu {
                MenuItem("Copy Value")
                    .onSelect { [weak self] in
                        guard let self else { return }
                        guard imagesTableView.hasValidClickedRow, let image = imagesTableViewDataSource.item(forRow: imagesTableView.clickedRow) else { return }
                        NSPasteboard.general.string = image.path
                    }
            }
        }
    }

    @IBAction func searchImagesButtonAction(_ sender: NSButton) {
        classDumpDyldController.searchImages()
    }

    @IBAction func targetArchRadioButtonAction(_ sender: NSButton) {
        guard let targetArch = ClassDumpDyldArch(rawValue: sender.tag) else { return }
        classDumpDyldController.selectTargetArch(targetArch)
    }

    @IBAction func showInFinderButtonAction(_ sender: NSButton) {
        FinderLauncher(url: classDumpDyldController.dyldSharedCacheURLForSelectedTargetArch).run()
    }

    @IBAction func openInHopperButtonAction(_ sender: NSButton) {
        HopperDisassemblerLauncher(executableURL: classDumpDyldController.dyldSharedCacheURLForSelectedTargetArch).run { result in
            switch result {
            case .success:
                break
            case let .failure(failure):
                NSAlert(error: failure).runModal()
            }
        }
    }
    
    @IBAction func openInIDAButtonAction(_ sender: NSButton) {
        IDALauncher(executableURL: classDumpDyldController.dyldSharedCacheURLForSelectedTargetArch).run { result in
            switch result {
            case .success:
                break
            case let .failure(failure):
                NSAlert(error: failure).runModal()
            }
        }
    }
}

extension ClassDumpDyldViewController: ClassDumpDyldControllerDelegate {
    public func classDumpDyldController(_ controller: ClassDumperCore.ClassDumpDyldController, didSearchImages images: [ClassDumperCore.ClassDumpableImage]) {
        var snapshot = imagesTableViewDataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(images.sorted(by: \.path), toSection: .main)
        imagesTableViewDataSource.apply(snapshot, .withoutAnimation)
    }

    public func classDumpDyldController(_ controller: ClassDumperCore.ClassDumpDyldController, didFailureSearchImagesWithError error: any Error) {
        DispatchQueue.main.async {
            NSAlert(error: error).runModal()
        }
    }
}

#endif
