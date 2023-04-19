//
//  SelectableLabel.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let selectableLabelOnEdit = NSNotification.Name("SelectableLabel.onEdit")
}

class SelectableLabel:
    UILabel,
    UITextViewDelegate
{
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.isHidden = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        tap.delaysTouchesBegan = true
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
    }

    var isInEditing = false {
        didSet {
            alpha = isInEditing ? 0.07 : 1
            textView.isHidden = !isInEditing
            invalidateIntrinsicContentSize()
            if isInEditing {
                NotificationCenter.default.post(name: .selectableLabelOnEdit, object: self)
            }
        }
    }

    var onEditingChanged: ((Bool) -> Void)?

    @objc private func onDoubleTap(_ sender: Any) {
        textView.isHidden = false
        if textView.becomeFirstResponder() {
            textView.text = text
            textView.font = font
            textView.selectAll(self)
        }
        if Current.defualts.chatSendClipboardWhenLabelEdit {
            let pasteboard = UIPasteboard.general
            pasteboard.string = text
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        isInEditing = true
        // Fix invalidateIntrinsicContentSize may not take effect immediately
        setNeedsLayout()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        isInEditing = false
        textView.text = nil
        assert(textView.isHidden)
        // Fix invalidateIntrinsicContentSize may not take effect immediately
        setNeedsLayout()
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if isInEditing {
            if size.width < 200 {
                size.width = 200
            }
        }
        return size
    }

    override var canBecomeFocused: Bool { false }
}

/*
 加上这个可以选择
 ```
 let selectionInteraction = UITextInteraction(for: .nonEditable)
 selectionInteraction.textInput = label
 label.addInteraction(selectionInteraction)
 ```

class SelectableLabel: UILabel, UITextInput {
    override var canBecomeFirstResponder: Bool {
        true // 需要
    }

    func text(in range: UITextRange) -> String? {
        nil  // 需要
    }

    func replace(_ range: UITextRange, withText text: String) {
    }

    var selectedTextRange: UITextRange? {
        get {
            .init() // 需要
        }
        set {

        }
    }

    var markedTextRange: UITextRange?

    var markedTextStyle: [NSAttributedString.Key: Any]?

    func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
    }

    func unmarkText() {
    }

    var beginningOfDocument: UITextPosition {
        get {
            .init()
        }
        set {

        }
    }

    var endOfDocument: UITextPosition {
        get {
            .init()
        }
        set {

        }
    }

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        nil
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        nil
    }

    func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        nil
    }

    func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        .orderedSame
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        0
    }

    var inputDelegate: UITextInputDelegate?

    var tokenizer: UITextInputTokenizer {
        self
    }

    func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        nil
    }

    func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        nil
    }

    func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        .natural
    }

    func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
    }

    func firstRect(for range: UITextRange) -> CGRect {
        bounds // 需要
    }

    func caretRect(for position: UITextPosition) -> CGRect {
        bounds // 需要
    }

    func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    func closestPosition(to point: CGPoint) -> UITextPosition? {
        nil // 需要
    }

    func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        nil
    }

    func characterRange(at point: CGPoint) -> UITextRange? {
        nil
    }

    var hasText: Bool {
        text?.isNotEmpty ?? false
    }

    func insertText(_ text: String) {
    }

    func deleteBackward() {
    }
}

extension SelectableLabel: UITextInputTokenizer {
    func rangeEnclosingPosition(_ position: UITextPosition, with granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextRange? {
        nil
    }

    func isPosition(_ position: UITextPosition, atBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        false
    }

    func position(from position: UITextPosition, toBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextPosition? {
        nil
    }

    func isPosition(_ position: UITextPosition, withinTextUnit granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        false
    }
}
 */
