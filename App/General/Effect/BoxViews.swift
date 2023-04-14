//
//  BoxViews.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

/// Background follow tint
class TintBackgroundView: UIView {
    @IBInspectable var tintAlpha: CGFloat = 1

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            updateUI()
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateUI()
    }

    private func updateUI() {
        backgroundColor = tintColor.withAlphaComponent(tintAlpha)
    }

    func tintAlpha(_ value: CGFloat) -> Self {
        tintAlpha = value
        return self
    }
}

/// With border
class SettingBox: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    private func setupStyle() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.opaqueSeparator.cgColor
        layer.cornerRadius = 10
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupStyle()
    }
}
