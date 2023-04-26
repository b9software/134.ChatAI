//
//  ChatTextView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import UIKit

class ChatTextView: UITextView {
    @IBOutlet weak var backgroundView: UIView?

    #if targetEnvironment(macCatalyst)
    override func makeTouchBar() -> NSTouchBar? {
        let bar = super.makeTouchBar()
        return bar
    }
    #endif

//    override var keyCommands: [UIKeyCommand]? {
//        [
//            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(handleEsc))
//        ]
//    }
//
//    @objc private func handleEsc() {
//        if resignFirstResponder() {
//            setNeedsFocusUpdate()
//        }
//    }

    var draftText: String? {
        get {
            if isFirstResponder {
                return text
            }
            return restoreTextForFirstResponder ?? text
        }
        set {
            if isFirstResponder {
                text = newValue
            } else {
                restoreTextForFirstResponder = newValue
                text = newValue?.replacingOccurrences(of: "\n", with: "\t")
            }
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        needsUpdateBackground.set()
    }

    override func becomeFirstResponder() -> Bool {
        needsUpdateBackground.set()
        if let value = restoreTextForFirstResponder {
            text = value
        }
        next(type: ConversationDetailViewController.self)?.textViewDidChange(self)
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        needsUpdateBackground.set()
        let value = text?.replacingOccurrences(of: "\n", with: "\t")
        if value != text {
            restoreTextForFirstResponder = text
            text = value
        } else {
            restoreTextForFirstResponder = nil
        }
        return super.resignFirstResponder()
    }

    private(set) var restoreTextForFirstResponder: String?
    private lazy var needsUpdateBackground = DelayAction(Action(target: self, selector: #selector(updateBackground)))

    @objc private func updateBackground() {
        guard let layer = backgroundView?.layer else { return }
        var borderWidth: CGFloat = 0
        if isFirstResponder { borderWidth += 1.5 }
        if isFocused { borderWidth += 0.5 }
        layer.borderWidth = borderWidth
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 5
        if isFocused {
            layer.shadowColor = tintColor.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 3
        } else {
            layer.shadowOpacity = 0
        }
    }
}
