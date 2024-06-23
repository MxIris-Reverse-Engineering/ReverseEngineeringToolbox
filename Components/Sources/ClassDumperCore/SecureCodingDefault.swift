import Foundation

@propertyWrapper
public final class SecureCodingDefault<T: NSObject & NSSecureCoding>: NSObject {
    public var wrappedValue: T {
        set {
            setDefault(forObject: newValue)
            currentValue = newValue
        }
        get {
            if let currentValue {
                return currentValue
            } else if let data = suite.data(forKey: key), let object = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: data) as? T {
                currentValue = object
                return object
            } else {
                setDefault(forObject: defaultValue)
                currentValue = defaultValue
                return defaultValue
            }
        }
    }

    private var currentValue: T? {
        willSet {
            if observeAllProperties {
                newValue?.addObserverForAllProperties(observer: self)
            }
        }

        didSet {
            if observeAllProperties {
                oldValue?.removeObserverForAllProperties(observer: self)
            }
        }
    }

    private let key: String

    private let suite: UserDefaults

    private let defaultValue: T

    private let classes: [AnyClass]

    private let observeAllProperties: Bool
    
    public init(key: String, suite: UserDefaults, defaultValue: T, classes: [AnyClass], observeAllProperties: Bool = true) {
        self.key = key
        self.suite = suite
        self.defaultValue = defaultValue
        self.observeAllProperties = observeAllProperties
        var classes = classes
        classes.append(T.self)
        self.classes = classes
        super.init()
    }

    private func setDefault(forObject object: T) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true) {
            suite.set(data, forKey: key)
            suite.synchronize()
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let currentValue {
            setDefault(forObject: currentValue)
        }
    }
}

private extension NSObject {
    func addObserverForAllProperties(
        observer: NSObject,
        options: NSKeyValueObservingOptions = [],
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        }
    }

    func removeObserverForAllProperties(
        observer: NSObject,
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            removeObserver(observer, forKeyPath: keyPath, context: context)
        }
    }

    func performForAllKeyPaths(_ action: (String) -> Void) {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(object_getClass(self), &count) else { return }
        defer { free(properties) }
        for i in 0 ..< Int(count) {
            let keyPath = String(cString: property_getName(properties[i]))
            action(keyPath)
        }
    }
}
