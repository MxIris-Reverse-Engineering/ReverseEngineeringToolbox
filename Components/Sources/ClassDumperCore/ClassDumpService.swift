//
//  ClassDumpService.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/4/19.
//

import AppKit
import Combine

public class ClassDumpService: NSObject {
    public static let performClassDumpNotification: Notification.Name = .init("ClassDumpService.performClassDumpNotification")

    public static let classDumpFileURLKey: String = "ClassDumpFileURLKey"

    public static let shared = ClassDumpService()
    
    public private(set) var fileURLBuffer: URL?
    
    @objc public func performClassDumpFromService(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let fileURL = pasteboard.string(forType: .fileURL)?.filePathURL.standardized {
            fileURLBuffer = fileURL
            NotificationCenter.default.post(name: Self.performClassDumpNotification, object: self, userInfo: [
                Self.classDumpFileURLKey: fileURL,
            ])
        }
    }
}
