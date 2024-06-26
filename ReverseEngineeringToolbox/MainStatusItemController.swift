//
//  MainStatusItemController.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/5/7.
//

import AppKit
import StatusItemController
import MenuBuilder
import SFSymbol

class MainStatusItemController: StatusItemController {
    static let shared = MainStatusItemController()

    func setup() {}

    private init() {
        super.init(image: SFSymbol(systemName: .wrenchAndScrewdriver).nsImage)
    }

    override func leftClickAction() {
        openMenu()
    }

    override func rightClickAction() {
        openMenu()
    }

    override func buildMenu() -> NSMenu {
        NSMenu {
            MenuItem("Show main window")
                .image(SFSymbol(systemName: .macwindow).nsImage)
                .onSelect {
                    NSApplication.shared.setActivationPolicy(.regular)
                    if #available(macOS 14.0, *) {
                        NSApplication.shared.activate()
                    } else {
                        NSApplication.shared.activate(ignoringOtherApps: true)
                    }
                    AppDelegate.shared.mainWindowController.showWindow(nil)
                }
            MenuItem("Quit")
                .image(SFSymbol(systemName: .power).nsImage)
                .onSelect { [unowned self] in
                    quit()
                }
        }
    }
}
