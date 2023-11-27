/*
 MBTableHeaderFooterView

 Copyright © 2018, 2023 BB9z.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

// @MBDependency:3
/**
 可以用 AutoLayout 自动调节高度的 tableHeaderView/tableFooterView

 使用：一般在 IB 中加一个 contentView 作为容器，然后用 AutoLayout 撑开 contentView

 A tableHeaderView/tableFooterView that can adjust height automatically with AutoLayout.

 Usage: Generally, add a contentView as a container in IB, and use AutoLayout to stretch the contentView.
 */
class MBTableHeaderFooterView: UIView, ResizeObserver {

    /// 子 view 的容器，MBTableHeaderFooterView 的高度会跟它的高度同步
    /// 如果不设置，高度不会自行改变
    ///
    /// The container of subviews. The height of MBTableHeaderFooterView will be synchronized with its height.
    /// If it is not set, the height will not change automatically.
    @IBOutlet weak var contentView: ResizeObservableView? {
        didSet {
            if contentView?.delegate == nil {
                contentView?.delegate = self
            }
        }
    }

    var tableView: UITableView? {
        superview as? UITableView
    }

    /// 刷新高度的方法，正常会自动更新，一般不用调用
    ///
    /// Update height method. It usually updates automatically, so it is not necessary to call it.
    func updateHeight() {
        guard let contentView = contentView else {
            return
        }
        layoutIfNeeded()
        height = contentView.height
        guard let tableView = self.tableView else {
            AppLog().error("MBTableHeaderFooterView’s superview must be a tableView. Current is \(superview?.description ?? "nil")")
            return
        }
        if tableView.tableHeaderView == self {
            tableView.tableHeaderView = self
        }
        if tableView.tableFooterView == self {
            tableView.tableFooterView = self
        }
    }

    func updateHeightAnimated(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, animated: animated, beforeAnimations: nil) {
            self.updateHeight()
        }
    }

    /// 代码方式安装为 tableHeaderView
    ///
    /// Install as tableHeaderView in code
    func setupAsHeaderView(to tableView: UITableView) {
        if tableView.tableHeaderView != self {
            removeFromSuperview()
            autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            translatesAutoresizingMaskIntoConstraints = true
        }
        tableView.tableHeaderView = self
    }

    /// 代码方式安装为 tableFooterView
    ///
    /// Install as tableFooterView in code
    func setupAsFooterView(to tableView: UITableView) {
        if tableView.tableFooterView != self {
            removeFromSuperview()
            autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            translatesAutoresizingMaskIntoConstraints = true
        }
        tableView.tableFooterView = self
    }

    func didResized(view: UIView, oldSize: CGSize) {
        guard view === contentView,
              let contentView = contentView,
              height != contentView.height else {
            return
        }
        updateHeight()
    }
}
