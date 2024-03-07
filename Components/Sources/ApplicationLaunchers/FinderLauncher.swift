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
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
