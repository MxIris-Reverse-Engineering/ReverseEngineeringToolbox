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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
