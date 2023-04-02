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
    StoryboardCreation,
    HasItem,
    ConversationUpdating
{
    static var storyboardID: StoryboardID { .conversation }

    var item: Conversation! {
        didSet {
            title = item.name
            item.delegates.add(self)
            item.requireUsableState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        conversation(item, useState: item.usableState)
    }

    @IBOutlet private weak var barLayoutContainer: UIView!
    @IBOutlet private weak var standardBar: UIView!
    @IBOutlet private weak var inputTextView: UITextView!
    @IBOutlet private var inputTextHeight: NSLayoutConstraint!
    @IBOutlet private weak var inputSendButton: UIButton!
    private var isInputExpand = false
}

extension ConversationDetailViewController {
    func conversation(_ item: Conversation, useState: Conversation.UsableState) {
        if useState == .forceSetup {
            if !children.contains(where: { $0 is ConversationSettingViewController }) {
                ConversationSettingViewController.showFrom(detail: self)
            }
        }
    }
}

// MARK: - Input

extension ConversationDetailViewController: UITextViewDelegate {
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: "\r", modifierFlags: .command, action: #selector(onSend)),
        ]
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        print("Send!")
        inputTextView.text = nil
        setInputExpand(false, animate: true)
    }
}
