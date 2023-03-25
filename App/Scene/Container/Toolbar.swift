//
//  Toolbar.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

class Toolbar: NSToolbar, NSToolbarDelegate {
    init() {
        super.init(identifier: .appMain)
        delegate = self
        displayMode = .iconOnly
        allowsUserCustomization = true
        showsBaselineSeparator = false
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar, .back, .flexibleSpace
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar, .back, .test, .test2,
            .flexibleSpace, .space
        ]
    }

    func toolbarImmovableItemIdentifiers(_ toolbar: NSToolbar) -> Set<NSToolbarItem.Identifier> {
        [.toggleSidebar, .back]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if ApplicationDelegate().debug.debugSystemUI {
            AppLog().debug("Toolbar> request item for \(itemIdentifier.rawValue)")
        }
        switch itemIdentifier {
        case .back: return .back()
        case .test: return .test()
        case .test2: return .test2()
        default: break
        }
        if let index = additionalItemsID.firstIndex(of: itemIdentifier) {
            return additionalItems[index]
        }
        return nil
    }

    private var additionalItemsID = [NSToolbarItem.Identifier]()
    private(set) var additionalItems = [NSToolbarItem]()

    func setAdditionalItems(_ additions: [NSToolbarItem]) {
        if additions == additionalItems { return }
        assert(delegate != nil)
        additionalItems.forEach {
            if let idx = items.firstIndex(of: $0) {
                removeItem(at: idx)
            }
        }
        additionalItemsID = additions.map { $0.itemIdentifier }
        additionalItems = additions
        additions.forEach {
            insertItem(withItemIdentifier: $0.itemIdentifier, at: items.count)
        }
    }

    @IBAction func toolBarTest(_ sender: Any) {
        debugPrint("test")
    }
}

extension NSToolbarItem {
    static func back() -> NSToolbarItem {
        let button = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: nil, action: #selector(RootViewController.toolbarBack))
        let item = NSToolbarItem(itemIdentifier: .back, barButtonItem: button)
        item.label = "Back"
        item.isNavigational = true
        return item
    }

    static func test() -> NSToolbarItem {
        let view = UILabel()
        view.text = "WWWWWWwwwwwwwww"
        view.backgroundColor = .red
        let button = UIBarButtonItem(customView: view)
        let item = NSToolbarItem(itemIdentifier: .test, barButtonItem: button)
        item.label = "Back"
        return item
    }

    static func test2() -> NSToolbarItem {
        let view = UILabel()
        view.text = "W"
        view.backgroundColor = .blue
        let button = UIBarButtonItem(customView: view)
        let item = NSToolbarItem(itemIdentifier: .test2, barButtonItem: button)
        return item
    }
}

extension NSToolbarItem.Identifier {
    static let back = NSToolbarItem.Identifier("app.back")
    static let test = NSToolbarItem.Identifier("app.test")
    static let test2 = NSToolbarItem.Identifier("app.test2")
}

extension NSToolbar.Identifier {
    static var appMain: Self {
        NSToolbar.Identifier("app.toolbar")
    }
}

// swiftlint:disable:next type_name
private final class _fixWarning {
    @IBAction func newWindowForTab(_ sender: Any?) {}
}

#endif
