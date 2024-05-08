//
//  MainSplitViewController.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/6.
//

import AppKit
import UIFoundation
import ClassDumperUI

class MainSplitViewController: NSSplitViewController {
    let classDumpViewController = ClassDumpViewController()
    let sidebarViewController = MainSidebarViewController()
    let tabViewController = NSTabViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarViewController.delegate = self
        tabViewController.tabStyle = .unspecified
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarViewController))
        addSplitViewItem(NSSplitViewItem(contentListWithViewController: tabViewController))
        tabViewController.addTabViewItem(NSTabViewItem(viewController: classDumpViewController))
    }
}

extension MainSplitViewController: MainSidebarViewControllerDelegate {
    func sidebar(_ sidebarViewController: MainSidebarViewController, didSelectItem item: Module) {
        tabViewController.selectedTabViewItemIndex = item.rawValue
    }
}
