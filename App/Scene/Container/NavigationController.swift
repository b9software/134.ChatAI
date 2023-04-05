//
//  NavigationController.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class NavigationController: B9NavigationController {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func handleViewControllersChanges() {
        super.handleViewControllersChanges()
        if let scene = view.window?.windowScene {
            scene.title = currentViewControllerTitle
        }
        updateToolbar()
    }

    var currentViewControllerTitle: String {
        topViewController?.navigationItem.title ?? topViewController?.title ?? L.App.name
    }

    func updateToolbar() {
#if targetEnvironment(macCatalyst)
        let toolItems: [NSToolbarItem] = topViewController?.navigationItem.rightBarButtonItems?.compactMap {
            let id = $0.action?.description ?? UUID().uuidString
            return NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(id), barButtonItem: $0)
        } ?? []
        NSToolbarController.of(view)?.update(additionalItems: toolItems)
#endif
    }
}

/**
 与 vc 绑定的工具栏按钮，为导航当前 vc 时显示
 */
extension UIViewController {
    @objc func operationMenu() -> UIMenu? { nil }
}
