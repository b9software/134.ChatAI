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
        let fixItems: [NSToolbarItem.Identifier]?
        let additionalItems: [NSToolbarItem]
        private var additionalItemsID = [NSToolbarItem.Identifier]()

        init(items: [NSToolbarItem.Identifier]) {
            self.fixItems = items
            self.additionalItems = []
        }

        init(additionalItems: [NSToolbarItem]) {
            self.fixItems = nil
            self.additionalItems = additionalItems
            additionalItemsID = additionalItems.map { $0.itemIdentifier }
        }

        func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            if let ids = fixItems { return ids }
            var ids: [NSToolbarItem.Identifier] = [
                .sidebar, .back, .flexibleSpace
            ]
            ids.append(contentsOf: additionalItemsID)
            return ids
        }

        func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            if let ids = fixItems { return ids }
            var ids: [NSToolbarItem.Identifier] = [
                .sidebar, .back, // .test, .test2,
                .flexibleSpace, .space
            ]
            ids.append(contentsOf: additionalItemsID)
            return ids
        }

        func toolbarImmovableItemIdentifiers(_ toolbar: NSToolbar) -> Set<NSToolbarItem.Identifier> {
            if let ids = fixItems { return Set(ids) }
            return [.sidebar, .back]
        }

        func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
            switch itemIdentifier {
            case .sidebar: return .toggleSidebar()
            case .back: return .back()
            case .floatCollapse: return .floatCollapse()
            case .floatExpand: return .floatExpand()
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
        if floatModeState.isFloat {
            additionalItems = newItems
            return
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

    var floatModeState = FloatModeState.normal {
        didSet {
            if oldValue == floatModeState { return }
            if floatModeState.isFloat {
                setFloatToolbar()
            } else {
                if let items = additionalItems {
                    additionalItems = nil
                    update(additionalItems: items)
                }
            }
        }
    }

    private func setFloatToolbar() {
        let newStatus = ToolbarStates(items: [floatModeState == .floatExpand ? .floatCollapse : .floatExpand])
        let newToolbar = NSToolbar(identifier: .appFloat)
        newToolbar.delegate = newStatus
        newToolbar.displayMode = .iconOnly
        newToolbar.allowsUserCustomization = false
        newToolbar.showsBaselineSeparator = false
        toolbarStatus = newStatus
        windowTitleBar.toolbar = newToolbar
    }
}

extension NSToolbarItem {
    static func toggleSidebar() -> NSToolbarItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "sidebar.leading"), style: .plain, target: nil, action: #selector(StandardActions.toggleSidebar))
        let item = NSToolbarItem(itemIdentifier: .sidebar, barButtonItem: button)
        item.label = L.Menu.navigationSidebar
        item.isNavigational = true
        return item
    }

    static func back() -> NSToolbarItem {
        let button = UIBarButtonItem(image: Asset.GeneralUI.Navigation.navBack.image, style: .plain, target: nil, action: #selector(StandardActions.goBack))
        let item = NSToolbarItem(itemIdentifier: .back, barButtonItem: button)
        item.label = L.Menu.navigationBack
        item.isNavigational = true
        return item
    }

    static func floatCollapse() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .floatCollapse)
        item.image = UIImage(systemName: "arrow.down.forward.and.arrow.up.backward")
        item.label = L.Menu.floatModeCollapse
        item.action = #selector(ApplicationDelegate.floatWindowCollapse)
        item.target = AppDelegate()
        item.visibilityPriority = .high
//        item.isNavigational = true
        return item
    }

    static func floatExpand() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .floatExpand)
        item.image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        item.label = L.Menu.floatModeExpand
        item.action = #selector(ApplicationDelegate.floatWindowExpand)
        item.target = AppDelegate()
        item.visibilityPriority = .high
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
    static let sidebar = NSToolbarItem.Identifier("app.sidebar")
    static let back = NSToolbarItem.Identifier("app.back")
    static let chatSetting = NSToolbarItem.Identifier("app.chat.setting")
    static let chatIntegration = NSToolbarItem.Identifier("app.chat.integration")
    static let floatExpand = NSToolbarItem.Identifier("app.floatMode.expand")
    static let floatCollapse = NSToolbarItem.Identifier("app.floatMode.collapse")
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
        NSToolbar.Identifier("app.toolbar.main")
    }

    static var appFloat: Self {
        NSToolbar.Identifier("app.toolbar.float")
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
