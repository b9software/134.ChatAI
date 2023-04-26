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
class B9RootViewController:
    UIViewController,
    GeneralSceneActivationAutoForward
{
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasBecomeActive = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hasBecomeActive = false
    }

//    func didBecomeActive() {
//        children.forEach { ($0 as? GeneralSceneActivation)?.hasBecomeActive = true }
//    }
//
//    func didBecomeHidden() {
//        children.forEach { ($0 as? GeneralSceneActivation)?.hasBecomeActive = false }
//    }
}

protocol GeneralSceneActivation: UIViewController {
    /// 这两个方法不直接调用
    func didBecomeActive()
    func didBecomeHidden()
}

import B9AssociatedObject

private let hasBecomeActiveAssociation = AssociatedObject<Bool>()

extension GeneralSceneActivation {
    /// GeneralSceneActivation 自动生成的标记
    var hasBecomeActive: Bool {
        get { hasBecomeActiveAssociation[self] ?? false }
        set {
            if hasBecomeActiveAssociation[self] == newValue { return }
            hasBecomeActiveAssociation[self] = newValue
            if newValue {
                didBecomeActive()
            } else {
                didBecomeHidden()
            }
        }
    }
}

/// 用在容器 vc 上，只需声明，自动实现
protocol GeneralSceneActivationAutoForward: GeneralSceneActivation {
}

extension GeneralSceneActivationAutoForward {
    func didBecomeActive() {
        children.forEach {
            ($0 as? GeneralSceneActivation)?.hasBecomeActive = true
        }
    }

    func didBecomeHidden() {
        children.forEach { ($0 as? GeneralSceneActivation)?.hasBecomeActive = false }
    }
}
