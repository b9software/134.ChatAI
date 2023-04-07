//
//  MessageListView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

/// 消息列表
class MessageListView: UITableView {
    /*
    var debugText: String {
        String(format: "ox%5.1f, ct%5.1f, %@", contentOffset.y, contentSize.height, bounds.size.debugDescription)
    }

    override var contentOffset: CGPoint {
        get { super.contentOffset }
        set {
            if isKeepBottom { return }
            super.contentOffset = newValue
        }
    }

    override var bounds: CGRect {
        didSet {
            if contentSize.height > bounds.height {
//                let diff = oldValue.height - bounds.height
//                guard diff > 0 else { return }
//                var offset = contentOffset
//                offset.y += diff
//                contentOffset = offset
            }
        }
    }

    override var contentSize: CGSize {
        willSet {
            if newValue == contentSize { return }
            AppLog().debug("\(debugText) <= begin contentSize will => \(newValue.height)")
            beginKeepBottom(newContentSize: newValue)
        }
        didSet {
            if oldValue == contentSize { return }
            endKeepBottom()
            AppLog().debug("\(debugText) <= end keep")
        }
    }

    private var offsetChange: CGFloat? {
        didSet {
            AppLog().debug("toBottomTrack = \(offsetChange?.description ?? "nil")")
        }
    }

    var isKeepBottom = false
    func beginKeepBottom(newContentSize: CGSize) {
        if newContentSize.height < bounds.height {
            return
        }
        if offsetChange != nil {
            AppLog().warning("begin but already in keep bottom")
            return
        }
        offsetChange = newContentSize.height - bounds.maxY
        isKeepBottom = true
    }

    func endKeepBottom() {
        defer { isKeepBottom = false }
        if contentSize.height < bounds.height {
            return
        }

        guard let diff = offsetChange else {
            AppLog().warning("end but already in keep bottom")
            return
        }
        defer { offsetChange = nil }
        guard diff > 0 else {
            AppLog().debug("igrnoal \(diff)")
            return
        }

        var offset = contentOffset
        offset.y += diff
        super.contentOffset = offset
        AppLog().debug("\(debugText) <= after update offset")
    }
     */
}

class MessageCellSizeView: UIView {
    @IBOutlet private weak var cell: UITableViewCell!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var isEnable = false {
        didSet {
            if isEnable {
                superview?.layoutIfNeeded()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
            updateLayout(oldBounds: oldValue, newBounds: bounds)
        }
    }

    private func updateLayout(oldBounds: CGRect, newBounds: CGRect) {
        guard let superview = superview, isEnable else {
            return
        }
        if abs(bounds.height - superview.height) < 1 { return }
        heightConstraint.constant = bounds.height
        updateCellHeight()
    }

    private func updateCellHeight() {
        guard let cell = cell,
              let table = cell.superview as? UITableView else {
            return
        }
        (table.dataSource as? MessageDataSource)?.updateHeight(heightConstraint.constant, for: cell)
    }
}

class MessageBaseCell:
    UITableViewCell,
    HasItem,
    MessageUpdating
{
    var item: Message! {
        didSet {
            if oldValue == item { return }
            oldValue?.delegates.remove(self)
            if let item = item {
                item.delegates.add(self)
                loadData()
            }
        }
    }

    private func loadData() {
        if item.fetchDetail() {
            messageDetailReady(item)
        } else {
            prepareAsyncLoad()
            sizeView?.isEnable = false
        }
    }

    func messageDetailReady(_ item: Message) {
        if self.item === item {
            updateUI(item: item)
            sizeView?.isEnable = true
        }
    }

    func prepareAsyncLoad() {
        // overwrite
    }

    func updateUI(item: Message) {
        // overwrite
    }

    @IBOutlet weak var sizeView: MessageCellSizeView?
}

class MessageMyTextCell: MessageBaseCell {
    static let id = "MyText"

    override func prepareAsyncLoad() {
        contentLabel.text = "..."
    }

    override func updateUI(item: Message) {
        contentLabel.text = item.cachedText
    }

    @IBOutlet private weak var contentLabel: UILabel!
}

class MessageUnsupportedCell: MessageBaseCell {
    static let id = "Unsupported"

    override func updateUI(item: Message) {
        textLabel?.text = "Unsupported"
        detailTextLabel?.text = "\(item.type) \(item.role?.rawValue ?? "?")"
    }
}
