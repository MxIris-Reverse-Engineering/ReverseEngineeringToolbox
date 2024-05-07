//
//  ClassDumpService.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/4/19.
//

import AppKit
import Combine

public enum ClassDumpService {
    public static let performClassDumpNotification: Notification.Name = .init("ClassDumpService.performClassDumpNotification")
    
    public static let classDumpFileURLKey: String = "ClassDumpFileURLKey"
    
    public static func performClassDumpFromService(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let fileURL = pasteboard.string(forType: .fileURL)?.filePathURL.standardized {
            NotificationCenter.default.post(name: Self.performClassDumpNotification, object: self, userInfo: [
                Self.classDumpFileURLKey: fileURL,
            ])
        }
    }
    
    public static func performService(fileURL: URL) throws {
        NotificationCenter.default.post(name: Self.performClassDumpNotification, object: self, userInfo: [
            Self.classDumpFileURLKey: fileURL,
        ])
        
    }
}
