/*
 B9RootViewController.swift

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/**
 As the root view controller of scene.

 It forwards the style or control method of the view controller to the first child.
 */
class B9RootViewController: UIViewController {
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
