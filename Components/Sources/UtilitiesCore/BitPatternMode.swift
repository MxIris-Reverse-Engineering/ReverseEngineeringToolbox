import Foundation

public struct BitPatternMode<Base> {
    public var base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BitPatternModeCompatible<Base> {
    associatedtype Base
    var bitPatternMode: BitPatternMode<Base> { set get }
    static var bitPatternMode: BitPatternMode<Base>.Type { set get }
}

extension BitPatternModeCompatible {
    public var bitPatternMode: BitPatternMode<Self> {
        set {}
        get { BitPatternMode(self) }
    }

    public static var bitPatternMode: BitPatternMode<Self>.Type {
        set {}
        get { BitPatternMode<Self>.self }
    }
}

extension String: BitPatternModeCompatible {}
extension Float: BitPatternModeCompatible {}
extension Float16: BitPatternModeCompatible {}
extension Double: BitPatternModeCompatible {}
extension CGFloat: BitPatternModeCompatible {}

extension BitPatternMode<String> {
    public var binaryStringToDouble: Double? {
        guard let bitPattern = UInt64(base, radix: 2) else { return nil }
        return Double(bitPattern: bitPattern)
    }

    public var binaryStringToCGFloat: CGFloat? {
        guard let bitPattern = UInt(base, radix: 2) else { return nil }
        return CGFloat(bitPattern: bitPattern)
    }

    public var binaryStringToFloat: Float? {
        guard let bitPattern = UInt32(base, radix: 2) else { return nil }
        return Float(bitPattern: bitPattern)
    }

    public var binaryStringToFloat16: Float16? {
        guard let bitPattern = UInt16(base, radix: 2) else { return nil }
        return Float16(bitPattern: bitPattern)
    }

    public var decimalStringToDouble: Double? {
        guard let bitPattern = UInt64(base, radix: 10) else { return nil }
        return Double(bitPattern: bitPattern)
    }

    public var decimalStringToCGFloat: CGFloat? {
        guard let bitPattern = UInt(base, radix: 10) else { return nil }
        return CGFloat(bitPattern: bitPattern)
    }

    public var decimalStringToFloat: Float? {
        guard let bitPattern = UInt32(base, radix: 10) else { return nil }
        return Float(bitPattern: bitPattern)
    }

    public var decimalStringToFloat16: Float16? {
        guard let bitPattern = UInt16(base, radix: 10) else { return nil }
        return Float16(bitPattern: bitPattern)
    }

    public var hexStringToDouble: Double? {
        guard let bitPattern = UInt64(base, radix: 16) else { return nil }
        return Double(bitPattern: bitPattern)
    }

    public var hexStringToCGFloat: CGFloat? {
        guard let bitPattern = UInt(base, radix: 16) else { return nil }
        return CGFloat(bitPattern: bitPattern)
    }

    public var hexStringToFloat: Float? {
        guard let bitPattern = UInt32(base, radix: 16) else { return nil }
        return Float(bitPattern: bitPattern)
    }

    public var hexStringToFloat16: Float16? {
        guard let bitPattern = UInt16(base, radix: 16) else { return nil }
        return Float16(bitPattern: bitPattern)
    }
}

extension BitPatternMode<Float16> {
    public var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    public var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}

extension BitPatternMode<Float> {
    public var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    public var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}

extension BitPatternMode<Double> {
    public var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    public var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}

extension BitPatternMode<CGFloat> {
    public var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    public var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}
