//
//  AppDelegate.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/4.
//

import Cocoa
import UIFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var mainWindowController = MainWindowController()

    static var shared: Self { NSApplication.shared.delegate as! Self }

    override init() {
        super.init()
        NSApplication.shared.servicesProvider = ServicesProvider.shared
        NSUpdateDynamicServices()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController.showWindow(nil)
        MainStatusItemController.shared.setup()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return false }
        mainWindowController.showWindow(nil)
        return false
    }
}
