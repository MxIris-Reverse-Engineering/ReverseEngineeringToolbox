//import Foundation
//@_exported public import enum ClassDumpDyld.ClassDumpDyldArch
//
//private import class ClassDumpDyld.ClassDumpDyldManager
//
//public protocol ClassDumpDyldControllerDelegate: AnyObject {
//    func classDumpDyldController(_ controller: ClassDumpDyldController, didSearchImages images: [ClassDumpableImage])
//    func classDumpDyldController(_ controller: ClassDumpDyldController, didFailureSearchImagesWithError error: Error)
//}
//
//public final class ClassDumpDyldController {
//    public weak var delegate: ClassDumpDyldControllerDelegate?
//
//    public private(set) var selectedTargetArch: ClassDumpDyldArch = .current
//
//    private let classDumpDyldManager = ClassDumpDyldManager.shared
//
//    public init() {}
//
//    public func searchImages() {
//        classDumpDyldManager.allImages { [weak self] images, error in
//            guard let self else { return }
//            if let images {
//                delegate?.classDumpDyldController(self, didSearchImages: images.map { ClassDumpableImage(path: $0) })
//            } else if let error {
//                delegate?.classDumpDyldController(self, didFailureSearchImagesWithError: error)
//            }
//        }
//    }
//
//    public func performDumpImage(_ image: ClassDumpableImage) {}
//
//    public func selectTargetArch(_ targetArch: ClassDumpDyldArch) {
//        selectedTargetArch = targetArch
//    }
//
//    public var dyldSharedCacheURLForSelectedTargetArch: URL {
//        classDumpDyldManager.dyldSharedCachePath(for: selectedTargetArch).filePathURL
//    }
//}
