//
//  MainWindowController.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/6.
//

import AppKit
import UIFoundation

class MainWindowController: PlainXiblessWindowController {
    lazy var mainSplitViewController = MainSplitViewController()
    
    lazy var mainToolbarController = MainToolbarController()
    
    override func windowDidLoad() {
        super.windowDidLoad()

        contentViewController = mainSplitViewController
        contentWindow.minSize = .init(width: 1100, height: 800)
        contentWindow.setFrame(.init(x: 0, y: 0, width: 1100, height: 800), display: true)
        contentWindow.center()
        contentWindow.title = "ReverseEngineeringToolbox"
        contentWindow.delegate = self
        contentWindow.toolbar = mainToolbarController.toolbar
    }
}

extension MainWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.setActivationPolicy(.accessory)
        return true
    }
}
