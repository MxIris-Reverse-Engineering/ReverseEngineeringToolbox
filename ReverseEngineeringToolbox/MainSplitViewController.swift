//
//  MainSplitViewController.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/6.
//

import AppKit
import UIFoundation
import ClassDumperUI
import UtilitiesUI

class MainSplitViewController: NSSplitViewController {
    let sidebarViewController = MainSidebarViewController()
    let tabViewController = NSTabViewController()
    let classDumpViewController = ClassDumpViewController()
    let utilitesViewController = UtilitiesViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarViewController.delegate = self
        tabViewController.tabStyle = .unspecified
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarViewController))
        addSplitViewItem(NSSplitViewItem(contentListWithViewController: tabViewController))
        tabViewController.addTabViewItem(NSTabViewItem(viewController: classDumpViewController))
        tabViewController.addTabViewItem(NSTabViewItem(viewController: utilitesViewController))
    }
}

extension MainSplitViewController: MainSidebarViewControllerDelegate {
    func sidebar(_ sidebarViewController: MainSidebarViewController, didSelectItem item: Module) {
        tabViewController.selectedTabViewItemIndex = item.rawValue
    }
}
