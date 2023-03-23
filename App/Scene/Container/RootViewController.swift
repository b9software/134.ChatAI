//
//  RootViewController.swift
//  App
//

import B9Action
import B9Condition
import UIKit

/**
 作为应用全局根 view controller

 内嵌主导航，这样如需遮盖导航的弹窗，可以加入到这里，比如启动闪屏、教程弹窗

 As the application global root view controller.

 Embed the main navigation view controller. Any pop-ups that need to cover the main navigation can be added here. Eg: splash, tutorial pop-ups.
 */
class RootViewController: B9RootViewController {

    private(set) var navigator: NavigationController!
    private(set) var split: SplitViewController!
    private(set) lazy var toolbar = Toolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        split = children.first { $0 is SplitViewController } as? SplitViewController
        navigator = split.children.first { $0 is NavigationController } as? NavigationController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if let titlebar = view.window?.windowScene?.titlebar {
//            titlebar.toolbarStyle = .unified
//            titlebar.toolbar = Toolbar()
//        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(toolbarBack) {
            return navigator.viewControllers.count > 1
        }
        return super.responds(to: aSelector)
    }

    @IBAction func toolbarBack(_ sender: Any) {
        navigator.popViewController(animated: true)
    }

    @IBAction private func gotoGuide(_ sender: Any) {
        navigator.pushViewController(GuideViewController.newFromStoryboard(), animated: false)
    }

    @IBAction private func gotoSetting(_ sender: Any) {
        navigator.pushViewController(SettingViewController.newFromStoryboard(), animated: false)
    }
}
