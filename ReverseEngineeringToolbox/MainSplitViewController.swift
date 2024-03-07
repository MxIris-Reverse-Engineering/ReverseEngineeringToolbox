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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSplitViewItem(NSSplitViewItem(contentListWithViewController: classDumpViewController))
    }
}
