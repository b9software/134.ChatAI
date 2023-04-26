//
//  MessageListView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import HasItem
import UIKit


// 未使用
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
    private var defaultHeight: CGFloat = 40
    @IBOutlet weak var heightConstraint: NSLayoutConstraint! {
        didSet {
            defaultHeight = heightConstraint.constant
        }
    }
    var isEnable = false {
        didSet {
            if isEnable {
                superview?.layoutIfNeeded()
            } else {
                heightConstraint.constant = defaultHeight
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
        if abs(bounds.height - superview.bounds.height) < 1 { return }
        heightConstraint.constant = bounds.height
        updateCellHeight()
    }

    private func updateCellHeight() {
        guard let cell = cell,
              let table = cell.superview as? UITableView else {
            return
        }
//        if #available(macCatalyst 16.0, *) {
//            cell.invalidateIntrinsicContentSize()
//        } else {
            (table.dataSource as? MessageDataSource)?.updateHeight(heightConstraint.constant, for: cell)
//        }
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
    var indexPath: IndexPath!

    var listDataSource: MessageDataSource? {
        cachedListDataSource ?? {
            if let result = (superview as? UITableView)?.dataSource as? MessageDataSource? {
                cachedListDataSource = result
                return result
            }
            return nil
        }()
    }
    private weak var cachedListDataSource: MessageDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionView?.isHidden = true
        focusEffect = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionView?.isHidden = !selected
        contentBox?.isSelected = selected
    }

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        commands.append(
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(delete))
        )
        return commands
    }

    override func delete(_ sender: Any?) {
        item.delete()
        listDataSource?.deleteFromCell(self)
    }

    override var canBecomeFocused: Bool { true }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        contentBox?.isParentFocused = isFocused
    }

    @IBOutlet private weak var selectionView: UIView?
    @IBOutlet private weak var contextSeparator: UIView?
    @IBOutlet private weak var contentTopMargin: NSLayoutConstraint?
    @IBOutlet weak var contentBox: MessageBoxView?
    @IBOutlet weak var sizeView: MessageCellSizeView?

    func updateUI(item: Message) {
        // overwrite
    }

    func prepareAsyncLoad() {
        // overwrite
    }

    private func loadData() {
        let isParent = indexPath.row == 0
        contextSeparator?.isHidden = !isParent
        contentTopMargin?.constant = isParent ? 30 : 0
        if item.fetchDetail() {
            messageDetailReady(item)
        } else {
            prepareAsyncLoad()
            sizeView?.isEnable = false
        }
        messageStateUpdate(item)
    }

    func messageDetailReady(_ item: Message) {
        if self.item === item {
            updateUI(item: item)
            sizeView?.isEnable = true
        }
    }

    func messageStateUpdate(_ item: Message) {
        // overwrite
    }

    func messageReceiveDeltaReplay(_ item: Message, text: String) {
        // overwrite
    }
}

class MessageMyTextCell: MessageBaseCell {
    static let id = "MyText"

    override func prepareAsyncLoad() {
        contentLabel.text = "..."
    }

    override func updateUI(item: Message) {
        contentLabel.text = item.cachedText ?? "❓"
    }

    @IBOutlet private weak var contentLabel: UILabel!
}

class MessageTextCell: MessageBaseCell {
    static let id = "Text"

    override var item: Message! {
        didSet {
            needsAppendReceive.cancel()
        }
    }

    override func prepareAsyncLoad() {
        contentLabel.text = "..."
    }

    override func updateUI(item: Message) {
        let couldRetry = item.state.couldRetry
        let isSending = item.senderState?.isSending == true
        retryButton.isHidden = !couldRetry

        if let err = item.senderState?.error, !AppError.isCancel(err) {
            contentLabel.textColor = .systemRed
            contentLabel.text = err.localizedDescription
            contentLabel.layoutIfNeeded()
            return
        } else {
            contentLabel.textColor = Asset.Text.first.color
        }
        if let text = item.cachedText {
            contentLabel.text = text
        } else if isSending {
            contentLabel.text = L.Chat.loading
        } else if item.state == .pend {
            contentLabel.text = L.Chat.loadingQueue
        } else {
            contentLabel.text = "❓"
        }
    }

    override func messageStateUpdate(_ item: Message) {
        super.messageStateUpdate(item)
        stopButton.isHidden = !(item.senderState?.isSending ?? false)
        if !stopButton.isHidden {
            // Fix indicator may not shown after cell recycling
            stopButton.configuration?.showsActivityIndicator = true
        }
        if let error = item.senderState?.error {
            updateUI(item: item)
        }
    }

    private lazy var needsAppendReceive = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.contentLabel.text = sf.item.cachedText
        sf.setNeedsLayout()
    }, delay: 0.2)
    override func messageReceiveDeltaReplay(_ item: Message, text: String) {
        needsAppendReceive.set()
    }

    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!

    @IBAction private func onRetry(_ sender: Any) {
        retryButton.isHidden = true
        item.retry { [weak self] item in
            guard let sf = self,
            sf.item == item else { return }
            sf.updateUI(item: item)
        }
    }

    @IBAction private func onStop(_ sender: Any) {
        item.stopResponse()
    }
}


class MessageUnsupportedCell: MessageBaseCell {
    static let id = "Unsupported"

    override func updateUI(item: Message) {
        textLabel?.text = "Unsupported"
        detailTextLabel?.text = "\(item.type) \(item.role?.rawValue ?? "?")"
    }
}
