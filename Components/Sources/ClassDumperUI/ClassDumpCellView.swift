//
//  ClassDumpCellView.swift
//  ClassDumper
//
//  Created by JH on 2024/2/25.
//

import AppKit
import SnapKit
import UIFoundation
import UIFoundationToolbox
import ClassDumperCore
import IDEIcons

class ClassDumpNameCellView: ImageTextTableCellView {
    
    protocol Configurable {
        var filename: String { get }
        var icon: NSImage? { get }
    }
    
    func configure(for file: Configurable) {
        textField?.stringValue = file.filename
        imageView?.image = file.icon.map { $0.box.toSize(.init(width: 18, height: 18)) }
    }
}

extension ClassDumpableFile: ClassDumpNameCellView.Configurable {
    var icon: NSImage? { type.icon }
}

extension ClassDumpableApplication: ClassDumpNameCellView.Configurable {
    var filename: String { displayName }
    var icon: NSImage? { NSWorkspace.shared.icon(forFile: url.path) }
}

extension ClassDumpableApplication.FrameworkDirectory: ClassDumpNameCellView.Configurable {
    var filename: String { name }
    var icon: NSImage? { .init(named: NSImage.folderName) }
}

//extension ClassDumpableApplication.Executable: ClassDumpNameCellView.Configurable {
//    var filename: String { url.lastPathComponent }
//    var icon: NSImage? { type.icon }
//}
//
//extension ClassDumpableApplication.Framework: ClassDumpNameCellView.Configurable {
//    var filename: String { url.lastPathComponent }
//    var icon: NSImage? { type.icon }
//}

extension String {
    var image: NSImage? {
        return Bundle.module.image(forResource: self)
    }
}


class ClassDumpTypeCellView: TableCellView {
    let typeImageView = NSImageView()

    override func setup() {
        super.setup()

        addSubview(typeImageView)

        typeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }
}

class ClassDumpOperationCellView: TableCellView {
    let showInFinderOperationButton: NSButton = .init()

    let openInHopperDisassemblerOperationButton: NSButton = .init()

    let dumpOperationButton: NSButton = .init()
    
    lazy var contentStackView = HStackView(spacing: 10) {
        showInFinderOperationButton
        openInHopperDisassemblerOperationButton
        dumpOperationButton
            .size(width: 20, height: 20)
    }

    override func setup() {
        super.setup()
        showInFinderOperationButton.image = Bundle.module.image(forResource: "FinderAppIcon").map { $0.box.toSize(.init(width: 20, height: 20)) }
        showInFinderOperationButton.isBordered = false
        openInHopperDisassemblerOperationButton.image = Bundle.module.image(forResource: "HopperDisassemblerAppIcon").map { $0.box.toSize(.init(width: 20, height: 20)) }
        openInHopperDisassemblerOperationButton.isBordered = false
        dumpOperationButton.image = IDEIcon("C", size: 18).image
        dumpOperationButton.isBordered = false
        
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class ClassDumpProgressCellView: TableCellView {
    let progressImageView: NSImageView = .init()

    let loadingView: NSProgressIndicator = .init()

    var state: ClassDumpingState = .ready {
        didSet {
            stateDidChange()
        }
    }

    func stateDidChange() {
        progressImageView.image = state.image
        progressImageView.contentTintColor = state.color
        progressImageView.isHidden = state == .loading
        loadingView.isHidden = state != .loading

        if state == .loading {
            loadingView.startAnimation(nil)
        } else {
            loadingView.stopAnimation(nil)
        }
    }

    override func setup() {
        super.setup()

        addSubview(progressImageView)
        addSubview(loadingView)
        
        progressImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }

        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(15)
        }

        loadingView.isIndeterminate = true
        loadingView.style = .spinning
        
        stateDidChange()
    }
}
