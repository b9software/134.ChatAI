//
//  XCTestCase+AssertView.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Foundation
import UIKit
import XCTest

enum XCViewPredicate {
    case has(Element)
    case no(Element)  // swiftlint:disable:this identifier_name

    enum Element {
        case button(Predicate)
        case label(Predicate)
        case image(Predicate)
        case kind(AnyClass)
        case predicate((UIView) -> (isMatch: Bool, skipSubviews: Bool))

        /// Second param means should stop checking subviews
        func matching(_ view: UIView) -> (Bool, Bool) {
            switch self {
            case .button(let predicate):
                if let button = view as? UIButton {
                    return (predicate.matching(button), true)
                }
            case .label(let predicate):
                if let label = view as? UILabel {
                    return (predicate.matching(label), true)
                }
                if view is UIButton {
                    return (false, true)
                }
            case .image(let predicate):
                if view is UIImageView || view is UIButton {
                    return (predicate.matching(view), true)
                }
            case .kind(let type):
                if view.isKind(of: type) {
                    return (true, true)
                }
            case .predicate(let predicate):
                return predicate(view)
            }
            return (false, false)
        }
    }

    enum Predicate {
        case any
        /// View has text equals given string.
        case textEqual(String)
        case textContents(String)
        /// Image content is same, supports image view and button.
        case image(UIImage)

        func matching(_ view: UIView) -> Bool {
            switch self {
            case .any:
                return true
            case .textEqual(let value):
                if let button = view as? UIButton {
                    return button.titleLabel?.text == value
                }
                if let label = view as? UILabel {
                    return label.text == value
                }
                return false
            case .textContents(let value):
                if let button = view as? UIButton {
                    return button.titleLabel?.text?.contains(value) == true
                }
                if let label = view as? UILabel {
                    return label.text?.contains(value) == true
                }
                return false
            case .image(let image):
                if let view = view as? UIImageView {
                    return image.isContentMatch(another: view.image)
                }
                if let button = view as? UIButton {
                    return image.isContentMatch(another: button.currentImage)
                }
                return false
            }
        }
    }

    var element: Element {
        switch self {
        case .has(let element):
            return element
        case .no(let element):
            return element
        }
    }

    var isTextChecking: Bool {
        switch element {
        case .button, .label:
            return true
        default:
            return false
        }
    }

    func matching(_ view: UIView) -> Bool {
        switch self {
        case .has(let element):
            if view.shouldSkipInTest { return false }
            let (result, stop) = element.matching(view)
            if stop || result { return result }
            for subView in view.subviews where matching(subView) {
                return true
            }
            return false
        case .no(let element):
            if view.shouldSkipInTest { return true }
            let (result, stop) = element.matching(view)
            if result { return false }
            if !stop {
                for subView in view.subviews where !matching(subView) {
                    return false
                }
            }
            return true
        }
    }
}

// MARK: - Shortcuts
extension XCViewPredicate {
    /// Predicate that has a label with the given text
    static func hasLabel(text: String) -> XCViewPredicate {
        .has(.label(.textEqual(text)))
    }

    /// Predicate that has any image view or button with the given image
    static func hasImage(_ image: UIImage) -> XCViewPredicate {
        .has(.image(.image(image)))
    }
}

extension XCTestCase {
    /**
     Assert a view has content matching given predicate.

     Factors to consider:

     - Subviews that are hidden will be passed.
     - Subviews with alpha less than 0.1 will be passed.
     */
    func assertView(
        _ view: UIView,
        _ predicate: XCViewPredicate,
        _ message: @autoclosure () -> String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if predicate.matching(view) { return }
        if predicate.isTextChecking {
            XCTFail(message() ?? "View content:\n\(view.findTexts())\nNot matching \(predicate)", file: file, line: line)
            return
        }
        XCTFail(message() ?? "View not matching \(predicate)", file: file, line: line)
    }
}

class AssertViewTests: XCTestCase {
    func testEmpty() {
        let view = UIView()
        assertView(view, .no(.button(.any)))
        assertView(view, .no(.label(.textEqual("zzz"))))
    }

    func testFailHas() {
        XCTExpectFailure()
        let view = UIView()
        assertView(view, .has(.button(.any)))
        assertView(view, .has(.label(.textEqual("zzz"))))
    }

    func testFailNo() {
        XCTExpectFailure()
        let view = UILabel()
        assertView(view, .no(.label(.any)))
    }

    func testButtonAndLabel() {
        let view = UIView()
        let button = UIButton()
        button.setTitle("button", for: .normal)
        let label = UILabel()
        label.text = "label"
        view.addSubview(button)
        view.addSubview(label)

        assertView(view, .has(.button(.textEqual("button"))))
        assertView(view, .no(.button(.textEqual("label"))))
        assertView(view, .hasLabel(text: "label"))
        assertView(view, .no(.label(.textEqual("button"))))

        button.isHidden = true
        assertView(view, .no(.button(.any)))

        label.alpha = 0
        assertView(view, .no(.label(.any)))
    }
}

// MARK: - View support

extension UIView {
    fileprivate var shouldSkipInTest: Bool {
        isHidden || alpha < 0.1
    }

    /// Iterate through the view hierarchy, find all the text content
    func findTexts() -> [String] {
        if shouldSkipInTest { return [] }
        var result = [String]()
        if let label = self as? UILabel {
            if let value = label.text {
                result.append(value)
            }
        }
        for sub in subviews {
            result.append(contentsOf: sub.findTexts())
        }
        return result
    }

    func findButton(_ matching: XCViewPredicate.Predicate) -> UIButton? {
        if shouldSkipInTest { return nil }
        if let button = self as? UIButton {
            if matching.matching(button) {
                return button
            }
        }
        for sub in subviews {
            if let button = sub.findButton(matching) {
                return button
            }
        }
        return nil
    }
}

protocol TestNeedsNavigator: XCTestCase {
    func navigator(rootViewController: UIViewController) -> XCNavigationController
}
extension TestNeedsNavigator {

    var navigatorWindow: UIWindow! {
        get { objc_getAssociatedObject(self, &navigatorWindowAssociation) as? UIWindow }
        set { objc_setAssociatedObject(self, &navigatorWindowAssociation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func navigator(rootViewController: UIViewController) -> XCNavigationController {
        var window = navigatorWindow
        if window == nil {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 360, height: 600))
            navigatorWindow = window
        }
        var result: XCNavigationController
        if let nav = window?.rootViewController as? XCNavigationController {
            result = nav
            if nav.viewControllers != [rootViewController] {
                nav.setViewControllers([rootViewController], animated: false)
            }
        } else {
            result = XCNavigationController(rootViewController: rootViewController)
        }
        result.view.layoutIfNeeded()
        return result
    }
}

private var navigatorWindowAssociation: UInt8 = 0

class XCNavigationController: UINavigationController {
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: false)
        viewControllers.last?.loadViewIfNeeded()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
        viewController.loadViewIfNeeded()
    }

    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }

    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        super.popToRootViewController(animated: false)
    }
}
