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

/**
 备忘：

 -

 */
class MessageTextView: UITextView {
    @IBOutlet private weak var fontRefrenceLabel: UILabel? {
        didSet {
            if let label = fontRefrenceLabel {
                font = label.font
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = CGSize(width: 1000, height: UIView.noIntrinsicMetric)
//        debugPrint(        superview?.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize))
        size = sizeThatFits(size)
        return size
//        if lastContentSize.equalTo(.zero) {
//            return bounds.size
//        }
//        return lastContentSize
    }

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        contentSizeObserver = observe(\.contentSize, changeHandler: { obj, change in
//            obj.lastContentSize = obj.contentSize
//        })
//    }
//
//    private var contentSizeObserver: NSKeyValueObservation?
//    private var lastContentSize: CGSize = .zero {
//        didSet {
//            if oldValue == lastContentSize { return }
//            invalidateIntrinsicContentSize()
//        }
//    }

    override var text: String! {
        didSet {
            if oldValue != text {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
            if oldValue.width != bounds.width {
                invalidateIntrinsicContentSize()
            }
        }
    }
}
