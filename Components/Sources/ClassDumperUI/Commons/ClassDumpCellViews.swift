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
import AssociatedObject
import FZSwiftUtils

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
    
//    @AssociatedObject(.retain(.nonatomic))
//    var _iconCache: NSImage? {
//        set {
//            setAssociatedValue(newValue, key: #function, object: self)
//        }
//        get {
//            getAssociatedValue(#function, object: self)
//        }
//    }
//    
//    
//    var icon: NSImage? {
//        if let iconCache = _iconCache {
//            return iconCache
//        } else {
//            let icon = NSWorkspace.shared.icon(forFile: url.path)
//            _iconCache = icon
//            return icon
//        }
//    }
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

    let openInIDAOperationButton: NSButton = .init()
    
    let dumpOperationButton: NSButton = .init()
    
    lazy var contentStackView = HStackView(spacing: 10) {
        showInFinderOperationButton
        openInHopperDisassemblerOperationButton
        openInIDAOperationButton
        dumpOperationButton
            .size(width: 20, height: 20)
    }

    override func setup() {
        super.setup()
        showInFinderOperationButton.image = .finderAppIcon(forSize: 20)
        showInFinderOperationButton.isBordered = false
        openInHopperDisassemblerOperationButton.image = .hopperAppIcon(forSize: 20)
        openInHopperDisassemblerOperationButton.isBordered = false
        openInIDAOperationButton.image = .idaAppIcon(forSize: 20)
        openInIDAOperationButton.isBordered = false
        dumpOperationButton.image = IDEIcon("C", size: 18).image
        dumpOperationButton.isBordered = false
        
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


extension CGSize: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Double) {
        self.init(width: value, height: value)
    }
    
    public init(integerLiteral value: Int) {
        self.init(width: value, height: value)
    }
}

extension NSImage {
    static func finderAppIcon(forSize size: CGSize) -> NSImage? {
        "FinderAppIcon".image?.box.toSize(size)
    }
    
    static func hopperAppIcon(forSize size: CGSize) -> NSImage? {
        "HopperDisassemblerAppIcon".image?.box.toSize(size)
    }
    
    static func idaAppIcon(forSize size: CGSize) -> NSImage? {
        "IDAProAppIcon".image?.box.toSize(size)
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
