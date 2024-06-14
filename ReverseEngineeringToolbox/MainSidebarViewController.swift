//
//  MainSidebarViewController.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/17.
//

import AppKit
import UIFoundation
import AdvancedCollectionTableView
import FZUIKit
import SnapKit

protocol MainSidebarViewControllerDelegate: AnyObject {
    func sidebar(_ sidebarViewController: MainSidebarViewController, didSelectItem item: Module)
}

class MainSidebarViewController: XiblessViewController<NSView> {
    private typealias DataSource = TableViewDiffableDataSource<Section, Module>

    public weak var delegate: MainSidebarViewControllerDelegate?

    private let (scrollView, tableView): (ScrollView, SingleColumnTableView) = SingleColumnTableView.scrollableTableView()

    private enum Section: CaseIterable, Hashable, Identifiable {
        case main
        var id: Self { self }
    }

    private lazy var tableViewDataSource: DataSource = {
        let cellRegistration = NSTableView.CellRegistration<NSTableCellView, Module> { cellView, tableColumn, row, item in
            var configuration = NSListContentConfiguration.sidebar()
            configuration.text = item.title
            cellView.contentConfiguration = configuration
        }
//        let sectionHeaderRegistration = NSTableView.SectionHeaderRegistration<NSTableSectionHeaderView, Section> { sectionHeaderView, row, section in
//            var contentConfiguration = NSListContentConfiguration.sidebarHeader()
//            contentConfiguration.text = "Module"
//            contentConfiguration.margins.leading += 10
//            sectionHeaderView.contentConfiguration = contentConfiguration
//        }
        let dataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration)
//        dataSource.applySectionHeaderViewRegistration(sectionHeaderRegistration)
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.left.right.bottom.equalToSuperview()
        }
        tableView.intercellSpacing = .init(width: 0, height: 5)
        tableView.style = .sourceList
        tableView.dataSource = tableViewDataSource

        setupSidebarData()
        setupSidebarHandler()
    }

    private func setupSidebarData() {
        var snapshot = tableViewDataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(Module.allCases, toSection: .main)
        tableViewDataSource.apply(snapshot, .withoutAnimation)
    }

    private func setupSidebarHandler() {
        tableViewDataSource.selectionHandlers.didSelect = { [weak self] items in
            guard let self, let item = items.first else { return }
            delegate?.sidebar(self, didSelectItem: item)
        }
    }
}
