//
//  MessageViews.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class MessageBoxView: UIView {
    var isSelected = false {
        didSet {
            if oldValue == isSelected { return }
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateUI()
    }

    private func updateUI() {
        layer.borderWidth = isSelected ? 2 : 0
        layer.borderColor = tintColor.cgColor
        if isSelected {
            layer.shadowColor = tintColor.cgColor
            layer.shadowOpacity = 1
        } else {
            layer.shadowOpacity = 0
        }
    }
}
