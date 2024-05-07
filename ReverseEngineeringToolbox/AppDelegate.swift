//
//  AppDelegate.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/3/4.
//

import Cocoa
import UIFoundation
import ClassDumperCore

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var mainWindowController = MainWindowController()

    override init() {
        super.init()
        NSApplication.shared.servicesProvider = ServicesProvider.shared
        NSUpdateDynamicServices()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return false }
        mainWindowController.showWindow(nil)
        return false
    }
}
