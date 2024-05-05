//
//  ShowInFinderLauncher.swift
//  ClassDumper
//
//  Created by JH on 2024/2/25.
//

import AppKit

public struct FinderLauncher {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func run() {
        let pasteboard = NSPasteboard.withUniqueName()
        pasteboard.clearContents()
        let urls = [url as NSURL]
        pasteboard.writeObjects(urls)
        NSPerformService("Finder/Reveal", pasteboard)
        pasteboard.releaseGlobally()
//        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
