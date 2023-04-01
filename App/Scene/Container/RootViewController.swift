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
    #if targetEnvironment(macCatalyst)
    private(set) lazy var toolbar = Toolbar()
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        split = children.first { $0 is SplitViewController } as? SplitViewController
        navigator = split.children.first { $0 is NavigationController } as? NavigationController
        #if targetEnvironment(macCatalyst)
        navigator.setNavigationBarHidden(true, animated: false)
        #endif
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
        adjustTraitCollection()
    }

    func adjustTraitCollection() {
        guard let vc = children.first else { return }
        let size = view.bounds.size

        #if targetEnvironment(macCatalyst)
        if let titleBar = view.window?.windowScene?.titlebar {
            let style: UITitlebarToolbarStyle = size.height > 500 ? .unified : .unifiedCompact
            if titleBar.toolbarStyle != style {
                titleBar.toolbarStyle = style
            }
        }
        #endif

        let currentCollection = overrideTraitCollection(forChild: vc) ?? .current
        let hClass = size.width > 500 ? UIUserInterfaceSizeClass.regular : .compact
        let vClass = size.height > 500 ? UIUserInterfaceSizeClass.regular : .compact
        if currentCollection.horizontalSizeClass == hClass,
           currentCollection.verticalSizeClass == vClass {
            return
        }
        let horizontal = UITraitCollection(horizontalSizeClass: hClass)
        let vertical = UITraitCollection(verticalSizeClass: vClass)
        let collection = UITraitCollection(traitsFrom: [currentCollection, horizontal, vertical])
        setOverrideTraitCollection(collection, forChild: vc)
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
        navigator.setViewControllers([GuideViewController.newFromStoryboard()], animated: false)
    }

    @IBAction private func gotoSetting(_ sender: Any) {
        navigator.setViewControllers([SettingViewController.newFromStoryboard()], animated: false)
    }

    @IBAction func orderFrontStandardAboutPanel(_ sender: Any) {
        navigator.pushViewController(AboutViewController.newFromStoryboard(), animated: true)
    }
}
