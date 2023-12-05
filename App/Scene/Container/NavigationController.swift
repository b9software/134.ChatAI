//
//  NavigationController.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class NavigationController: B9NavigationController {

    var onViewControllerChanged: ((NavigationController) -> Void)?

    override func handleViewControllersChanges() {
        super.handleViewControllersChanges()
        if let scene = view.window?.windowScene {
            scene.title = currentViewControllerTitle
        }
        updateToolbar()
        onViewControllerChanged?(self)
    }

    var currentViewControllerTitle: String {
        topViewController?.navigationItem.title ?? topViewController?.title ?? L.App.name
    }

    func updateToolbar() {
#if targetEnvironment(macCatalyst)
        let toolbar = NSToolbarController.of(view)
        if let provider = topViewController as? ToolbarItemProvider {
            toolbar?.update(additionalItems: provider.additionalToolbarItems())
        } else {
            toolbar?.update(additionalItems: [])
        }
#endif
    }
}
