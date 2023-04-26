//
//  Toolbar.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

class NSToolbarController {
    private class ToolbarStates: NSObject, NSToolbarDelegate {
        let additionalItems: [NSToolbarItem]
        private var additionalItemsID = [NSToolbarItem.Identifier]()

        init(additionalItems: [NSToolbarItem]) {
            self.additionalItems = additionalItems
            additionalItemsID = additionalItems.map { $0.itemIdentifier }
        }

        func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            var ids: [NSToolbarItem.Identifier] = [
                .toggleSidebar, .back, .flexibleSpace
            ]
            ids.append(contentsOf: additionalItemsID)
            return ids
        }

        func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            var ids: [NSToolbarItem.Identifier] = [
                .toggleSidebar, .back, // .test, .test2,
                .flexibleSpace, .space
            ]
            ids.append(contentsOf: additionalItemsID)
            return ids
        }

        func toolbarImmovableItemIdentifiers(_ toolbar: NSToolbar) -> Set<NSToolbarItem.Identifier> {
            [.toggleSidebar, .back]
        }

        func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
            switch itemIdentifier {
            case .back: return .back()
//            case .test: return .test()
//            case .test2: return .test2()
            default: break
            }
            if let index = additionalItemsID.firstIndex(of: itemIdentifier) {
                return additionalItems[index]
            }
            return nil
        }
    }

    var windowTitleBar: UITitlebar!
    private var toolbarStatus: ToolbarStates?
    private(set) var additionalItems: [NSToolbarItem]?

    func update(additionalItems newItems: [NSToolbarItem]) {
        if additionalItems == newItems {
            if windowTitleBar.toolbar != nil {
                return
            }
        }
        // Due to system bug, have to create a new toolbar every time.
        // When there are multiple windows, removeItem(at:) may go out of bounds.
        let newStatus = ToolbarStates(additionalItems: newItems)
        let newToolbar = NSToolbar(identifier: .appMain)
        newToolbar.delegate = newStatus
        newToolbar.displayMode = .iconOnly
        newToolbar.allowsUserCustomization = true
        newToolbar.showsBaselineSeparator = false
        additionalItems = newItems
        toolbarStatus = newStatus
        windowTitleBar.toolbar = newToolbar
    }
}

extension NSToolbarItem {
    static func back() -> NSToolbarItem {
        let button = UIBarButtonItem(image: Asset.GeneralUI.Navigation.navBack.image, style: .plain, target: nil, action: #selector(StandardActions.goBack))
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
    static let chatSetting = NSToolbarItem.Identifier("app.chat.setting")
    static let chatIntegration = NSToolbarItem.Identifier("app.chat.integration")
    static let test = NSToolbarItem.Identifier("app.test")
    static let test2 = NSToolbarItem.Identifier("app.test2")
}

extension NSToolbarItem {
    func config(with barItem: UIBarButtonItem) -> Self {
        if let value = barItem.title {
            label = value
        }
        image = barItem.image
        target = barItem.target
        action = barItem.action
        isBordered = true
        return self
    }

    func priority(_ visibility: NSToolbarItem.VisibilityPriority) -> Self {
        visibilityPriority = visibility
        return self
    }
}

extension NSMenuToolbarItem {
    func menu(_ menu: UIMenu) -> Self {
        itemMenu = menu
        showsIndicator = false
        return self
    }
}

extension NSToolbar.Identifier {
    static var appMain: Self {
        NSToolbar.Identifier("app.toolbar")
    }
}

protocol ToolbarItemProvider {
    func additionalToolbarItems() -> [NSToolbarItem]
}

extension ToolbarItemProvider where Self: UIViewController {
    func additionalToolbarItems() -> [NSToolbarItem] {
        let toolItems: [NSToolbarItem] = navigationItem.rightBarButtonItems?.compactMap {

            let id = $0.action?.description ?? UUID().uuidString
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(id), barButtonItem: $0)
            if $0.tag == 1 {
                item.visibilityPriority = .low
            }
            return item
        } ?? []
        return toolItems.reversed()
    }
}

#else

protocol ToolbarItemProvider {}

#endif
