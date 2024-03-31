#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import UIFoundation
import ClassDumperCore
import AdvancedCollectionTableView
import FZUIKit

public class ModuleXibViewController: XibViewController {
    public override class var nibBundle: Bundle { .module }
}

public final class ClassDumpDyldViewController: ModuleXibViewController {
    private typealias DataSource = TableViewDiffableDataSource<TableViewSection, ClassDumpableImage>
    
    private typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, ClassDumpableImage>

    @IBOutlet var systemVersionValueLabel: NSTextField!

    @IBOutlet var searchImagesButton: NSButton!

    @IBOutlet var performDumpAllImageButton: NSButton!

    @IBOutlet var imagesTableView: NSTableView!

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

        imagesTableView.dataSource = imagesTableViewDataSource
    }

    @IBAction func searchImagesButtonAction(_ sender: NSButton) {
        classDumpDyldController.searchImages()
    }
}

extension ClassDumpDyldViewController: ClassDumpDyldControllerDelegate {
    public func classDumpDyldController(_ controller: ClassDumperCore.ClassDumpDyldController, didSearchImages images: [ClassDumperCore.ClassDumpableImage]) {
        var snapshot = imagesTableViewDataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(images, toSection: .main)
        imagesTableViewDataSource.apply(snapshot, .withoutAnimation)
    }

    public func classDumpDyldController(_ controller: ClassDumperCore.ClassDumpDyldController, didFailureSearchImagesWithError error: any Error) {
        DispatchQueue.main.async {
            NSAlert(error: error).runModal()
        }
    }
}

#endif
