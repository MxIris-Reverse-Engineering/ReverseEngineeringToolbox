//
//  ServicesProvider.swift
//  ReverseEngineeringToolbox
//
//  Created by JH on 2024/5/6.
//

import AppKit
import ClassDumperCore
import ApplicationLaunchers

@objc
class ServicesProvider: NSObject {
    static let shared = ServicesProvider()
    
    @objc public func performClassDumpFromService(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        ClassDumpService.performClassDumpFromService(pasteboard, userData: userData, error: error)
    }
    
    @objc public func performOpenInIDAFromService(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let fileURL = pasteboard.string(forType: .fileURL)?.filePathURL.standardized {
            let executableURL = if let bundle = Bundle(url: fileURL), let executableURL = bundle.executableURL {
                executableURL
            } else {
                fileURL
            }
            
            IDALauncher(executableURL: executableURL).run { result in
                switch result {
                case .success:
                    break
                case .failure(let failure):
                    error.pointee = failure.localizedDescription as NSString
                }
            }
        }
    }
    
    @objc public func performOpenInHopperFromService(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let fileURL = pasteboard.string(forType: .fileURL)?.filePathURL.standardized {
            let executableURL = if let bundle = Bundle(url: fileURL), let executableURL = bundle.executableURL {
                executableURL
            } else {
                fileURL
            }
            HopperDisassemblerLauncher(executableURL: executableURL).run { result in
                switch result {
                case .success:
                    break
                case .failure(let failure):
                    error.pointee = failure.localizedDescription as NSString
                }
            }
        }
    }
}
