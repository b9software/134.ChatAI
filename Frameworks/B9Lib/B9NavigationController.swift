//
//  B9NavigationController.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class B9NavigationController: UINavigationController, UINavigationControllerDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        onInit()
    }

    func onInit() {
    }

    private var lastViewControllers = [UIViewController]() {
        didSet {
            if oldValue == lastViewControllers { return }
            let vcRemoved = oldValue.filter { !lastViewControllers.contains($0) }
            let vcAdded = lastViewControllers.filter { !oldValue.contains($0) }
            if !vcRemoved.isEmpty {
                handleViewControllers(remove: vcRemoved)
            }
            if !vcAdded.isEmpty {
                handleViewControllers(add: vcAdded)
            }
            handleViewControllersChanges()
        }
    }

    /// 处理新增，默认什么也不做
    func handleViewControllers(add vcs: [UIViewController]) {
        AppLog().info("vc add \(vcs)")
    }

    /// 处理移除，默认什么也不做
    func handleViewControllers(remove vcs: [UIViewController]) {
        AppLog().info("vc remove \(vcs)")
    }

    /// 堆栈变化时调用，需调用 super
    func handleViewControllersChanges() {
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        lastViewControllers = viewControllers
    }

    @IBAction func navigationPop(_ sender: Any) {
        popViewController(animated: true)
    }
}