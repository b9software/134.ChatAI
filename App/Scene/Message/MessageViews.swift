//
//  MessageViews.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

/// Selectable
class MessageBoxView: UIView {
    var isSelected = false {
        didSet {
            if oldValue == isSelected { return }
            updateUI()
        }
    }

    var isParentFocused = false {
        didSet {
            if oldValue == isParentFocused { return }
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateUI()
    }

    private func updateUI() {
        var borderWidth: CGFloat = 0
        if isSelected { borderWidth += 1.5 }
        if isParentFocused { borderWidth += 0.5 }
        layer.borderWidth = borderWidth
        layer.borderColor = tintColor.cgColor
        if isParentFocused {
            layer.shadowColor = tintColor.cgColor
            layer.shadowOpacity = 1
        } else {
            layer.shadowOpacity = 0
        }
    }
}
