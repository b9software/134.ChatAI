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

 It should forward the style or control method of the view controller to the first child.
 */
class RootViewController: UIViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        MBApp.status().rootViewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Style/Control forward
extension RootViewController {
    private var _keyViewController: UIViewController? {
        children.first
    }

    override var shouldAutorotate: Bool {
        _keyViewController?.shouldAutorotate ?? true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        _keyViewController?.supportedInterfaceOrientations ?? .all
    }

    override var childForStatusBarStyle: UIViewController? {
        _keyViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        _keyViewController
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        _keyViewController
    }

    override var childViewControllerForPointerLock: UIViewController? {
        _keyViewController
    }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        _keyViewController
    }

    override func childContaining(_ source: UIStoryboardUnwindSegueSource) -> UIViewController? {
        _keyViewController
    }
}
