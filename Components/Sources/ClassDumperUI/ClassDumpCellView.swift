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

class ClassDumpNameCellView: ImageTextTableCellView {
    func configure(for file: ClassDumpableFile) {
        textField?.stringValue = file.filename
        switch file.type {
        case .framework:
            imageView?.image = Bundle.module.image(forResource: "FrameworkIcon").map { $0.box.toSize(.init(width: 18, height: 18)) }
        case .executable:
            imageView?.image = Bundle.module.image(forResource: "ExecutableBinaryIcon").map { $0.box.toSize(.init(width: 18, height: 18)) }
        }
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

    lazy var contentStackView = HStackView(spacing: 10) {
        showInFinderOperationButton
        openInHopperDisassemblerOperationButton
    }

    override func setup() {
        super.setup()
        showInFinderOperationButton.image = Bundle.module.image(forResource: "FinderAppIcon").map { $0.box.toSize(.init(width: 20, height: 20)) }
        showInFinderOperationButton.isBordered = false
        openInHopperDisassemblerOperationButton.image = Bundle.module.image(forResource: "HopperDisassemblerAppIcon").map { $0.box.toSize(.init(width: 20, height: 20)) }
        openInHopperDisassemblerOperationButton.isBordered = false

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
