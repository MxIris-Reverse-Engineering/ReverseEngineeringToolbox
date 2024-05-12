import AppKit
import Combine

public final class FloatingPointConvertController {
    public enum Precision: Int, CaseIterable, Hashable {
        case float16
        case float32
        case double
    }

    @Published public var decimalString: String = "" {
        didSet {
            if isChanging { return }
            decimalStringDidChange()
        }
    }

    @Published public var binaryString: String = "" {
        didSet {
            if isChanging { return }
            binaryStringDidChange()
        }
    }

    @Published public var hexadecimalString: String = "" {
        didSet {
            if isChanging { return }
            hexadecimalStringDidChange()
        }
    }

    @Published public var currentPrecision: Precision = .double {
        didSet {
            if isChanging { return }
            currentPrecisionDidChange()
        }
    }

    private var isChanging: Bool = false

    private func performChange(_ block: () -> Void) {
        isChanging = true
        block()
        isChanging = false
    }

    public init() {}

    private func decimalStringDidChange() {
        performChange {
            switch currentPrecision {
            case .float16:
                if let float16Value = Float16(decimalString) {
                    binaryString = float16Value.bitPatternMode.binaryString
                    hexadecimalString = float16Value.bitPatternMode.hexString
                } else {
                    binaryString = ""
                    hexadecimalString = ""
                }
            case .float32:
                if let float32Value = Float(decimalString) {
                    binaryString = float32Value.bitPatternMode.binaryString
                    hexadecimalString = float32Value.bitPatternMode.hexString
                } else {
                    binaryString = ""
                    hexadecimalString = ""
                }
            case .double:
                if let doubleValue = Double(decimalString) {
                    binaryString = doubleValue.bitPatternMode.binaryString
                    hexadecimalString = doubleValue.bitPatternMode.hexString
                } else {
                    binaryString = ""
                    hexadecimalString = ""
                }
            }
        }
    }

    private func binaryStringDidChange() {
        performChange {
            switch currentPrecision {
            case .float16:
                if let float16Value = binaryString.bitPatternMode.binaryStringToFloat16 {
                    decimalString = float16Value.description
                    hexadecimalString = float16Value.bitPatternMode.hexString
                } else {
                    decimalString = ""
                    hexadecimalString = ""
                }
            case .float32:
                if let float32Value = binaryString.bitPatternMode.binaryStringToFloat {
                    decimalString = float32Value.description
                    hexadecimalString = float32Value.bitPatternMode.hexString
                } else {
                    decimalString = ""
                    hexadecimalString = ""
                }
            case .double:
                if let doubleValue = binaryString.bitPatternMode.binaryStringToDouble {
                    decimalString = doubleValue.description
                    hexadecimalString = doubleValue.bitPatternMode.hexString
                } else {
                    decimalString = ""
                    hexadecimalString = ""
                }
            }
        }
    }

    private func hexadecimalStringDidChange() {
        performChange {
            switch currentPrecision {
            case .float16:
                if let float16Value = hexadecimalString.bitPatternMode.hexStringToFloat16 {
                    binaryString = float16Value.bitPatternMode.binaryString
                    decimalString = float16Value.description
                } else {
                    binaryString = ""
                    decimalString = ""
                }
            case .float32:
                if let float32Value = hexadecimalString.bitPatternMode.hexStringToFloat {
                    binaryString = float32Value.bitPatternMode.binaryString
                    decimalString = float32Value.description
                } else {
                    binaryString = ""
                    decimalString = ""
                }
            case .double:
                if let doubleValue = hexadecimalString.bitPatternMode.hexStringToDouble {
                    binaryString = doubleValue.bitPatternMode.binaryString
                    decimalString = doubleValue.description
                } else {
                    binaryString = ""
                    decimalString = ""
                }
            }
        }
    }

    private func currentPrecisionDidChange() {
        performChange {
            decimalString = ""
            binaryString = ""
            hexadecimalString = ""
        }
    }
}
