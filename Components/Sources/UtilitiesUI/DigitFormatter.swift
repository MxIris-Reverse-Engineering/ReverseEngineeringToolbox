#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

class HexDigitFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        if string.allSatisfy(\.isHexDigit) {
            return string.uppercased()
        } else {
            var string = string
            string.removeAll { !$0.isHexDigit }
            return string.uppercased()
        }
    }

//    override func editingString(for obj: Any) -> String? {
//        guard let string = obj as? String else { return nil }
//        if string.allSatisfy(\.isHexDigit) {
//            return string.uppercased()
//        } else {
//            var string = string
//            string.removeAll { !$0.isHexDigit }
//            return string.uppercased()
//        }
//    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if string.allSatisfy(\.isHexDigit) {
            obj?.pointee = string.uppercased() as NSString
            return true
        } else {
            var string = string
            string.removeAll { !$0.isHexDigit }
            obj?.pointee = string.uppercased() as NSString
            return false
        }
    }
}

class BinaryDigitFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        if string.allSatisfy(\.isBinaryDigit) {
            return string
        } else {
            var string = string
            string.removeAll { !$0.isBinaryDigit }
            return string
        }
    }

//    override func editingString(for obj: Any) -> String? {
//        guard let string = obj as? String else { return nil }
//        if string.allSatisfy(\.isBinaryDigit) {
//            return string
//        } else {
//            var string = string
//            string.removeAll { !$0.isBinaryDigit }
//            return string
//        }
//    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if string.allSatisfy(\.isBinaryDigit) {
            obj?.pointee = string as NSString
            return true
        } else {
            var string = string
            string.removeAll { !$0.isBinaryDigit }
            obj?.pointee = string as NSString
            return true
        }
    }
}

extension Character {
    var isBinaryDigit: Bool {
        self == "0" || self == "1"
    }
}

#endif
