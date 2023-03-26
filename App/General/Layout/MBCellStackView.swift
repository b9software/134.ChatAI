/*
 MBCellStackView

 Copyright © 2018-2019, 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import HasItem
import UIKit

// @MBDependency:1
/**
 复用填充一组 view

 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
class MBCellStackView<ViewType: UIView, ObjectType>: UIStackView {
    var items = [ObjectType]() {
        didSet {
            if oldValue.count != items.count {
                _updateArrangedViews()
            }
            _updateViewItem()
        }
    }

    var cellNib: UINib?
    @IBInspectable private var cellNibName: String? {
        didSet {
            cellNib = UINib(nibName: cellNibName!, bundle: nil)
        }
    }

    var configureCell: ((MBCellStackView<ViewType, ObjectType>, ViewType, Int, ObjectType) -> Void)?

    private func _updateArrangedViews() {
        guard let cellNib = cellNib else { return }
        let oldCount = arrangedSubviews.count
        let newCount = items.count
        if oldCount == newCount { return }
        if oldCount > newCount {
            let viewsToRemove = arrangedSubviews[newCount..<oldCount]
            viewsToRemove.forEach { removeSubview($0) }
            return
        }
        for _ in oldCount..<newCount {
            guard let view = cellNib.instantiate(withOwner: self, options: nil).first as? ViewType else { break }
            addArrangedSubview(view)
        }
    }

    private func _updateViewItem() {
        for (idx, view) in arrangedSubviews.enumerated() {
            let item = items.element(at: idx)
            if let config = configureCell,
               let view = view as? ViewType,
               let item = item {
                config(self, view, idx, item)
            }
            if var view = view as? AnyHasItem {
                view.setItem(item)
            }
        }
    }
}
