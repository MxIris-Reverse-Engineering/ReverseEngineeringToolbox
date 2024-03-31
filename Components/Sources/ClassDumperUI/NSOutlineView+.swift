#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import FZUIKit
import AssociatedObject

extension NSOutlineView {
    // MARK: - Empty Collection View

    /// The view that is displayed when the datasource doesn't contain any items.
    ///
    /// When using this property, ``emptyContentConfiguration`` is set to `nil`.
    @AssociatedObject(.retain(.nonatomic))
    var emptyView: NSView? = nil {
        didSet {
            guard oldValue != emptyView else { return }
            oldValue?.removeFromSuperview()
            if emptyView != nil {
                emptyContentConfiguration = nil
                updateEmptyView()
            }
        }
    }

    /// The content configuration that content view is displayed when the datasource doesn't contain any items.
    ///
    /// When using this property, ``emptyView`` is set to `nil`.
    @AssociatedObject(.retain(.nonatomic))
    var emptyContentConfiguration: NSContentConfiguration? = nil {
        didSet {
            if let configuration = emptyContentConfiguration {
                emptyView = nil
                if let emptyContentView = emptyContentView {
                    emptyContentView.contentConfiguration = configuration
                } else {
                    emptyContentView = .init(configuration: configuration)
                }
                updateEmptyView()
            } else {
                emptyContentView?.removeFromSuperview()
                emptyContentView = nil
            }
        }
    }

    /// The handler that gets called when the data source switches between an empty and non-empty snapshot or viceversa.
    ///
    /// You can use this handler e.g. if you want to update your empty view or content configuration.
    ///
    /// - Parameter isEmpty: A Boolean value indicating whether the current snapshot is empty.
    @AssociatedObject(.retain(.nonatomic))
    var emptyHandler: ((_ isEmpty: Bool) -> Void)? {
        didSet {
            emptyHandler?(isEmpty)
        }
    }

    @AssociatedObject(.retain(.nonatomic))
    private var emptyContentView: ContentConfigurationView?

    private func updateEmptyView(previousIsEmpty: Bool? = nil) {
        if !isEmpty {
            emptyView?.removeFromSuperview()
            emptyContentView?.removeFromSuperview()
        } else if let emptyView = emptyView, emptyView.superview != self {
            addSubview(withConstraint: emptyView)
        } else if let emptyContentView = emptyContentView, emptyContentView.superview != self {
            addSubview(withConstraint: emptyContentView)
        }
        if let emptyHandler = emptyHandler, let previousIsEmpty = previousIsEmpty {
            if previousIsEmpty != isEmpty {
                emptyHandler(isEmpty)
            }
        }
    }

    private var isEmpty: Bool {
        numberOfRows <= 0
    }
    /// A view that displays the content view of a `NSContentConfiguration`.
    private class ContentConfigurationView: NSView {
        /// The content view.
        var contentView: NSView & NSContentView

        /// The current content configuration.
        public var contentConfiguration: NSContentConfiguration {
            didSet {
                updateContentView()
            }
        }

        func updateContentView() {
            if contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                contentView.removeFromSuperview()
                contentView = contentConfiguration.makeContentView()
                addSubview(withConstraint: contentView)
            }
        }

        /// Creates a view with the specified content configuration.
        public init(configuration: NSContentConfiguration) {
            self.contentConfiguration = configuration
            self.contentView = configuration.makeContentView()
            super.init(frame: .zero)
            addSubview(withConstraint: contentView)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



#endif
