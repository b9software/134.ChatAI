/*
 MBSceneStackView

 Copyright © 2018, 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

// @MBDependency:2
/**
 基于 UIStackView 的界面切换

 把 UIStackView 中的 view 分成若干组，每次显示一组，并支持组间切换显示

 UIStackView based views switching

 Divide the views in the UIStackView into several groups, display one group at a time, and support switching between groups
 */
class MBSceneStackView: UIStackView {

    private(set) var activeSceneIndex = 0

    var scenes = [[UIView]]() {
        didSet {
            for (index, views) in scenes.enumerated() {
                views.forEach { $0.isHidden = index != activeSceneIndex }
            }
        }
    }

    var onSceneChanged: ((MBSceneStackView, Int) -> Void)?

    func setActiveScene(at index: Int, animated: Bool, layoutView: UIView? = nil) {
        guard index < scenes.count else { return }

        let sceneNeedHide = scenes[activeSceneIndex]
        let sceneNeedShow = scenes[index]
        let transform: CGFloat = (activeSceneIndex < index) ? 100 : -100
        activeSceneIndex = index

        if let onSceneChanged = onSceneChanged {
            onSceneChanged(self, index)
        }

        if !animated {
            sceneNeedHide.forEach { $0.isHidden = true }
            sceneNeedShow.forEach { $0.isHidden = false }
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            sceneNeedHide.forEach {
                $0.alpha = 0
                $0.transform = CGAffineTransform(translationX: -transform, y: 0)
            }
        } completion: { _ in
            sceneNeedHide.forEach {
                $0.isHidden = true
                $0.alpha = 1
                $0.transform = CGAffineTransform.identity
            }
            sceneNeedShow.forEach {
                $0.isHidden = false
                $0.alpha = 0
                $0.transform = CGAffineTransform(translationX: transform, y: 0)
            }
            (layoutView ?? self).layoutIfNeeded()

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                sceneNeedShow.forEach {
                    $0.alpha = 1
                    $0.transform = CGAffineTransform.identity
                }
            }
        }
    }

    func nextScene(animated: Bool) {
        setActiveScene(at: activeSceneIndex + 1, animated: animated)
    }

    func previousScene(animated: Bool) {
        setActiveScene(at: activeSceneIndex - 1, animated: animated)
    }
}
