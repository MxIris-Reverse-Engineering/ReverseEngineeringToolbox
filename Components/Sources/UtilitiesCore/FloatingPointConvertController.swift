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
            decimalStringDidChange()
        }
    }

    @Published public var binaryString: String = "" {
        didSet {
            binaryStringDidChange()
        }
    }

    @Published public var hexadecimalString: String = "" {
        didSet {
            hexadecimalStringDidChange()
        }
    }

    @Published public var currentPrecision: Precision = .double {
        didSet {
            currentPrecisionDidChange()
        }
    }

    public init() {}
    
    private func decimalStringDidChange() {
        switch currentPrecision {
        case .float16:
            if let float16Value = decimalString.bitPatternMode.decimalStringToFloat16 {
                binaryString = float16Value.bitPatternMode.binaryString
                hexadecimalString = float16Value.bitPatternMode.hexString
            } else {
                binaryString = ""
                hexadecimalString = ""
            }
        case .float32:
            if let float32Value = decimalString.bitPatternMode.decimalStringToFloat {
                binaryString = float32Value.bitPatternMode.binaryString
                hexadecimalString = float32Value.bitPatternMode.hexString
            } else {
                binaryString = ""
                hexadecimalString = ""
            }
        case .double:
            if let doubleValue = decimalString.bitPatternMode.decimalStringToDouble {
                binaryString = doubleValue.bitPatternMode.binaryString
                hexadecimalString = doubleValue.bitPatternMode.hexString
            } else {
                binaryString = ""
                hexadecimalString = ""
            }
        }
    }

    private func binaryStringDidChange() {
        switch currentPrecision {
        case .float16:
            if let float16Value = decimalString.bitPatternMode.binaryStringToFloat16 {
                decimalString = float16Value.description
                hexadecimalString = float16Value.bitPatternMode.hexString
            } else {
                decimalString = ""
                hexadecimalString = ""
            }
        case .float32:
            if let float32Value = decimalString.bitPatternMode.binaryStringToFloat {
                decimalString = float32Value.description
                hexadecimalString = float32Value.bitPatternMode.hexString
            } else {
                decimalString = ""
                hexadecimalString = ""
            }
        case .double:
            if let doubleValue = decimalString.bitPatternMode.binaryStringToDouble {
                decimalString = doubleValue.description
                hexadecimalString = doubleValue.bitPatternMode.hexString
            } else {
                decimalString = ""
                hexadecimalString = ""
            }
        }
    }

    private func hexadecimalStringDidChange() {
        switch currentPrecision {
        case .float16:
            if let float16Value = decimalString.bitPatternMode.hexStringToFloat16 {
                binaryString = float16Value.bitPatternMode.binaryString
                decimalString = float16Value.description
            } else {
                binaryString = ""
                decimalString = ""
            }
        case .float32:
            if let float32Value = decimalString.bitPatternMode.hexStringToFloat {
                binaryString = float32Value.bitPatternMode.binaryString
                decimalString = float32Value.description
            } else {
                binaryString = ""
                decimalString = ""
            }
        case .double:
            if let doubleValue = decimalString.bitPatternMode.hexStringToDouble {
                binaryString = doubleValue.bitPatternMode.binaryString
                decimalString = doubleValue.description
            } else {
                binaryString = ""
                decimalString = ""
            }
        }
    }

    private func currentPrecisionDidChange() {
        decimalString = ""
        binaryString = ""
        hexadecimalString = ""
    }
}
