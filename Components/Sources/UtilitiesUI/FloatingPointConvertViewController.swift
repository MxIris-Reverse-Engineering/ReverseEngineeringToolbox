#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import Combine
import CombineCocoa
import UtilitiesCore
import UIFoundationToolbox
import FZUIKit

class FloatingPointConvertViewController: ModuleXibViewController {
    private let convertController = FloatingPointConvertController()

    @IBOutlet var segmentedControl: NSSegmentedControl!
    @IBOutlet var decimalTextField: NSTextField!
    @IBOutlet var hexadecimalTextField: NSTextField!
    @IBOutlet var binaryTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFormatters()
        setupBindings()
//        setupGestures()
    }

    func setupFormatters() {
        hexadecimalTextField.formatter = HexDigitFormatter()
        binaryTextField.formatter = BinaryDigitFormatter()
    }

    func setupGestures() {
        decimalTextField.box.addGestureRecognizer(for: ClickGestureRecognizerConfiguration(numberOfClicks: 2)) { [weak self] _ in
            guard let self, !decimalTextField.stringValue.isEmpty else { return }
            NSPasteboard.general.string = decimalTextField.stringValue
        }
        
        hexadecimalTextField.box.addGestureRecognizer(for: ClickGestureRecognizerConfiguration(numberOfClicks: 2)) { [weak self] _ in
            guard let self, !hexadecimalTextField.stringValue.isEmpty else { return }
            NSPasteboard.general.string = hexadecimalTextField.stringValue
        }

        binaryTextField.box.addGestureRecognizer(for: ClickGestureRecognizerConfiguration(numberOfClicks: 2)) { [weak self] _ in
            guard let self, !binaryTextField.stringValue.isEmpty else { return }
            NSPasteboard.general.string = binaryTextField.stringValue
        }
    }

    func setupBindings() {
        decimalTextField.combine.textDidChangePublisher().assign(on: convertController, to: \.decimalString).cancel(in: cancellable)
        hexadecimalTextField.combine.textDidChangePublisher().assign(on: convertController, to: \.hexadecimalString).cancel(in: cancellable)
        binaryTextField.combine.textDidChangePublisher().assign(on: convertController, to: \.binaryString).cancel(in: cancellable)
        convertController.$decimalString.bind(to: decimalTextField.combine.stringValue).cancel(in: cancellable)
        convertController.$hexadecimalString.bind(to: hexadecimalTextField.combine.stringValue).cancel(in: cancellable)
        convertController.$binaryString.bind(to: binaryTextField.combine.stringValue).cancel(in: cancellable)
        segmentedControl.combine.selectedSegmentPublisher().compactMap { FloatingPointConvertController.Precision(rawValue: $0) }.assign(on: convertController, to: \.currentPrecision).cancel(in: cancellable)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Self.Failure == Never {
    public func assign<Root>(on object: Root, to keyPath: ReferenceWritableKeyPath<Root, Self.Output>) -> AnyCancellable {
        assign(to: keyPath, on: object)
    }
}

#endif
