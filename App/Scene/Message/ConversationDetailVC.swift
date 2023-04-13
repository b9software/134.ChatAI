//
//  ConversationDetailVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class ConversationDetailViewController:
    UIViewController,
    ConversationUpdating,
    HasItem,
    StoryboardCreation,
    UITableViewDelegate
{
    static var storyboardID: StoryboardID { .conversation }

    var item: Conversation! {
        didSet {
            title = item.name
            navigationItem.title = item.name
            item.delegates.add(self)
            item.requireUsableState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        conversation(item, useState: item.usableState)
        listDataSource.conversation = item
        listView.allowsFocus = true
        listView.selectionFollowsFocus = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onSelectionLabelEdit), name: .selectableLabelOnEdit, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .selectableLabelOnEdit, object: nil)
    }

    @IBOutlet private weak var settingButtonItem: UIBarButtonItem!

    @IBOutlet private weak var listView: UITableView!
    private lazy var listDataSource = MessageDataSource(tableView: listView)
    var isReadingHistory = false {
        didSet {
            if oldValue == isReadingHistory { return }
            AppLog().debug("CD> isReadingHistory => \(isReadingHistory)")
        }
    }

    @IBOutlet private weak var barLayoutContainer: UIView!
    @IBOutlet private weak var standardBar: UIView!
    @IBOutlet private weak var inputTextView: UITextView!
    @IBOutlet private var inputTextHeight: NSLayoutConstraint!
    @IBOutlet private weak var inputSendButton: UIButton!
    private var isInputExpand = false
    private var isInputAllowed = false {
        didSet {
            inputTextView.isEditable = isInputAllowed
            inputSendButton.isEnabled = isInputAllowed
        }
    }
    private var inputReplyMessage: Message?
}

extension ConversationDetailViewController {
    func conversation(_ item: Conversation, useState: Conversation.UsableState) {
        if useState == .forceSetup {
            if !children.contains(where: { $0 is ConversationSettingViewController }) {
                ConversationSettingViewController.showFrom(detail: self, animate: false)
            }
        }
        isInputAllowed = useState == .normal
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [listView, inputTextView]
    }
    override var canBecomeFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        ApplicationMenu.setNeedsRevalidate()
        return super.becomeFirstResponder()
    }

    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()
        if isInputAllowed {
            commands.append(.init(input: "\r", modifierFlags: .command, action: #selector(onSend)))
        }
        return commands
    }
}

// MARK: - Setting

extension ConversationDetailViewController {
    var currentSetting: ConversationSettingViewController? {
        children.first(where: { $0 is ConversationSettingViewController }) as? ConversationSettingViewController
    }

    // StandardActions
    @IBAction func gotoChatSetting(_ sender: Any?) {
        toggleSetting(sender)
    }

    @IBAction func toggleSetting(_ sender: Any?) {
        if let vc = currentSetting {
            if item.usableState == .forceSetup {
                return
            }
            vc.dismiss(animate: true)
        } else {
            ConversationSettingViewController.showFrom(detail: self, animate: true)
        }
    }
}

// MARK: -

extension ConversationDetailViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIFocusSystem.focusSystem(for: tableView)?.requestFocusUpdate(to: cell)
        }
    }

    @objc private func onSelectionLabelEdit(_ notice: Notification) {
        guard let label = notice.object as? SelectableLabel,
              let cell = label.next(type: MessageBaseCell.self) else {
            assert(false)
            return
        }
        let ip = listView.indexPath(for: cell)
        listView.selectRow(at: ip, animated: false, scrollPosition: .none)
    }

    var isLastCellVisible: Bool {
        let lastRow = listView.numberOfRows(inSection: 0) - 1
        return listView.indexPathsForVisibleRows?.contains(IndexPath(row: lastRow, section: 0)) == true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == listView {
            isReadingHistory = !isLastCellVisible
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == listView {
//            if scrollView.contentOffset.y < 200 {
//                listDataSource.loadHistory()
//            }
        }
//        AppLog().debug("didscroll \(scrollView.contentOffset), tracking: \(scrollView.isTracking), Drag:\(scrollView.isDragging)")
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if scrollView == listView {
            listView.scrollToLastRow(animated: true)
        }
        return false
    }
}

// MARK: - Input

extension ConversationDetailViewController: UITextViewDelegate {
    // 可以 track +shift
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        debugPrint("begin", presses)
//        super.pressesBegan(presses, with: event)
//    }
//    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        debugPrint("end", presses)
//        super.pressesEnded(presses, with: event)
//    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\t" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let layoutSize = textView.sizeThatFits(textView.size)
        let lineHeight = textView.font?.pointSize ?? 20
        let isMultiline = ((layoutSize.height - 22) / lineHeight) > 2
        if isInputExpand {
            if !isMultiline,
               layoutSize.width < (textView.width * 0.8) {
                setInputExpand(false, animate: true)
            }
        } else {
            if isMultiline {
                setInputExpand(true, animate: true)
            }
        }
    }

    private func setInputExpand(_ expand: Bool, animate: Bool) {
        if isInputExpand == expand { return }
        isInputExpand = expand
        UIView.animate(withDuration: 0.3, delay: 0, animated: animate, beforeAnimations: nil, animations: { [self] in
            inputTextView.font = UIFont.preferredFont(forTextStyle: expand ? .callout : .body)
            inputTextHeight.constant = expand ? 300 : 46
            view.layoutIfNeeded()
        })
    }

    @IBAction private func onSend() {
        if let text = inputTextView.text.trimmed() {
            item.send(text: text, reply: inputReplyMessage)
        }
        inputTextView.text = nil
        setInputExpand(false, animate: true)
    }
}
