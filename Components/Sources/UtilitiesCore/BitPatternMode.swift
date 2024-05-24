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

public extension BitPatternModeCompatible {
    var bitPatternMode: BitPatternMode<Self> {
        set {}
        get { BitPatternMode(self) }
    }

    static var bitPatternMode: BitPatternMode<Self>.Type {
        set {}
        get { BitPatternMode<Self>.self }
    }
}

extension String: BitPatternModeCompatible {}
extension Float: BitPatternModeCompatible {}

#if arch(arm64)
extension Float16: BitPatternModeCompatible {}
#endif

extension Double: BitPatternModeCompatible {}
extension CGFloat: BitPatternModeCompatible {}

public extension BitPatternMode<String> {
    var binaryStringToDouble: Double? {
        guard let bitPattern = UInt64(base, radix: 2) else { return nil }
        return Double(bitPattern: bitPattern)
    }

    var hexStringToDouble: Double? {
        guard let bitPattern = UInt64(base, radix: 16) else { return nil }
        return Double(bitPattern: bitPattern)
    }

    var binaryStringToCGFloat: CGFloat? {
        guard let bitPattern = UInt(base, radix: 2) else { return nil }
        return CGFloat(bitPattern: bitPattern)
    }

    var hexStringToCGFloat: CGFloat? {
        guard let bitPattern = UInt(base, radix: 16) else { return nil }
        return CGFloat(bitPattern: bitPattern)
    }

    var binaryStringToFloat: Float? {
        guard let bitPattern = UInt32(base, radix: 2) else { return nil }
        return Float(bitPattern: bitPattern)
    }

    var hexStringToFloat: Float? {
        guard let bitPattern = UInt32(base, radix: 16) else { return nil }
        return Float(bitPattern: bitPattern)
    }

    #if arch(arm64)
    var binaryStringToFloat16: Float16? {
        guard let bitPattern = UInt16(base, radix: 2) else { return nil }
        return Float16(bitPattern: bitPattern)
    }

    var hexStringToFloat16: Float16? {
        guard let bitPattern = UInt16(base, radix: 16) else { return nil }
        return Float16(bitPattern: bitPattern)
    }
    #endif
}

#if arch(arm64)
public extension BitPatternMode<Float16> {
    var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}
#endif

public extension BitPatternMode<Float> {
    var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}

public extension BitPatternMode<Double> {
    var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}

public extension BitPatternMode<CGFloat> {
    var binaryString: String {
        .init(base.bitPattern, radix: 2)
    }

    var hexString: String {
        .init(base.bitPattern, radix: 16)
    }
}
