/*
 MBHighlightTintImageView.swift

 Copyright © 2020, 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9Action
import UIKit

/**
 图片主题色根据高亮状态变化的 image view

 注意：iOS 11-12 第一屏的图片可能还需要用 UIImageView+MBRenderingMode 修正一下
 */
class MBHighlightTintImageView: UIImageView {

    @IBInspectable var normalTintColor: UIColor? {
        didSet { needsUpdateTint.set() }
    }
    @IBInspectable var highlightTintColor: UIColor? {
        didSet { needsUpdateTint.set() }
    }

    override var isHighlighted: Bool {
        didSet { needsUpdateTint.set() }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        needsUpdateTint.set()
    }

    var intendedTintColor: UIColor? {
        if let color = normalTintColor {
            if !isHighlighted {
                return color
            }
        }
        if let color = highlightTintColor {
            if isHighlighted {
                return color
            }
        }
        return nil
    }

    func setNeedsUpdateTintColor() {
        needsUpdateTint.set()
    }

    private lazy var needsUpdateTint = DelayAction(Action { [weak self] in
        self?.doUpdateTint()
    })

    private func doUpdateTint() {
        let newTintColor = intendedTintColor ?? superview?.tintColor
        if tintColor != newTintColor {
            tintColor = newTintColor
        }
    }
}
