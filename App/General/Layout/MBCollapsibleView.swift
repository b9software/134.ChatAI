/*
 MBCollapsibleView

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

class MBCollapsibleView: UIView, ResizeObserver {
    @IBOutlet var contentView: ResizeObservableView! {
        didSet {
            if contentView.delegate == nil {
                contentView.delegate = self
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
    }

    private(set) var isCollapsed = false {
        didSet {
            if oldValue == isCollapsed { return }
            invalidateIntrinsicContentSize()
        }
    }

    func setCollapsed(_ collapsed: Bool, animated: Bool) {
        isCollapsed = collapsed
        UIView.animate(withDuration: 0.2, delay: 0, animated: animated, beforeAnimations: nil, animations: { [self] in
            contentView.alpha = collapsed ? 0 : 1
            superview?.layoutIfNeeded()
        })
    }

    override var intrinsicContentSize: CGSize {
        isCollapsed ? .zero : contentView.size
    }

    func didResized(view: UIView, oldSize: CGSize) {
        invalidateIntrinsicContentSize()
    }
}
