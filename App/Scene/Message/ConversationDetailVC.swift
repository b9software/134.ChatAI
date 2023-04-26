//
//  ConversationDetailVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import HasItem
import UIKit

class ConversationDetailViewController:
    UIViewController,
    ConversationUpdating,
    GeneralSceneActivation,
    HasItem,
    StoryboardCreation,
    ToolbarItemProvider,
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
        isInputAllowed = false
        inputActionContainer.isHidden = true
        inputActionStateLabel.text = nil
        conversation(item, useState: item.usableState)
        listDataSource.conversation = item
        listDataSource.itemMayRemove = { [weak self] _ in
            self?.deselectReplyItemForListChangeIfNeeded()
        }
        listView.allowsFocus = true
        listView.selectionFollowsFocus = true
//        if #available(macCatalyst 16.0, *) {
//            listView.selfSizingInvalidation = .enabled
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasBecomeActive = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hasBecomeActive = false
    }

    private weak var lastFocusedItem: UIFocusEnvironment?
    @IBOutlet private weak var integrationBarItem: UIBarButtonItem! {
        didSet {
            integrationBarItem.menu = buildIntegrationMenu()
        }
    }
    @IBOutlet private weak var settingButtonItem: UIBarButtonItem!
#if targetEnvironment(macCatalyst)
    private lazy var templateSlider: NSSliderTouchBarItem = {
        let item = NSSliderTouchBarItem(identifier: .chatTemperature)
        item.label = "Temperature"
        item.minimumSliderWidth = 60
        item.maximumSliderWidth = 160
        item.doubleValue = Double(self.item.engineConfig.temperature)
        item.target = self
        item.action = #selector(onTemperatureSliderChanged)
        return item
    }()
#endif

    @IBOutlet private weak var listView: UITableView!
    private lazy var listDataSource = MessageDataSource(tableView: listView)
    var isReadingHistory = false {
        didSet {
            if oldValue == isReadingHistory { return }
            AppLog().debug("CD> isReadingHistory => \(isReadingHistory)")
        }
    }

    @IBOutlet private weak var barLayoutContainer: UIView!
    @IBOutlet private weak var barLayoutBottom: NSLayoutConstraint!
    @IBOutlet private weak var standardBar: UIView!
    @IBOutlet private weak var inputActionContainer: UIView!
    @IBOutlet private weak var inputActionStateLabel: UILabel!
    @IBOutlet private weak var inputTextView: ChatTextView!
    @IBOutlet private var inputTextHeight: NSLayoutConstraint!
    @IBOutlet private weak var inputSendButton: UIButton!
    private var isInputExpand = false
    private var isInputAllowed = false {
        didSet {
            barLayoutContainer.isHidden = !isInputAllowed
            barLayoutBottom.constant = isInputAllowed ? 0 : barLayoutContainer.height
        }
    }
    private var inputSendby: Sendby {
        let current = Sendby(item?.chatConfig.sendbyKey) ?? Current.defualts.preferredSendbyKey
        if lastSendby != current {
            lastSendby = current
            updateSendButton(sendby: current)
        }
        return current
    }
    private var lastSendby: Sendby?
    private var sendbyTrackIsShiftPressed = false

    @IBOutlet private weak var replySelectionButton: UIButton!
    private var shouldUpdateReplySelectionForNewMessage = false
    private var inputReplyItems: [Message]?

    @IBOutlet private weak var tellMoreButton: UIButton!
    private lazy var needsItemSelectionUpdate = DelayAction(Action(target: self, selector: #selector(updateItemSelectionChange)))
}

extension ConversationDetailViewController {
    #if targetEnvironment(macCatalyst)
    func additionalToolbarItems() -> [NSToolbarItem] {
        [
            NSMenuToolbarItem(itemIdentifier: .chatIntegration)
                .menu(buildIntegrationMenu())
                .priority(.low)
                .config(with: integrationBarItem),
            NSToolbarItem(itemIdentifier: .chatSetting)
                .config(with: settingButtonItem),
        ]
    }

    override func makeTouchBar() -> NSTouchBar? {
        TouchbarController.of(view)?.makeTouchbar(
            items: [.chatSettingBar, .otherItemsProxy],
            template: [templateSlider]
        )
    }

    @objc private func onTemperatureSliderChanged(_ sender: NSSliderTouchBarItem) {
        let value = Float(sender.doubleValue)
        var engineCfg = item.engineConfig
        if abs(engineCfg.temperature - value) < 0.02 { return }
        engineCfg.temperature = value
        item.engineConfig = engineCfg
    }

    #endif

    func buildIntegrationMenu() -> UIMenu {
        UIMenu(title: "Integration", children: [
            UICommand(title: L.Menu.integrationHelp, action: #selector(gotoAppIntegrationHelp)),
            UICommand(title: L.Menu.integrationBookmark, action: #selector(onCopyJSBookmark))
        ])
    }

    func conversation(_ item: Conversation, useState: Conversation.UsableState) {
        if useState == .forceSetup {
            if !children.contains(where: { $0 is ConversationSettingViewController }) {
                ConversationSettingViewController.showFrom(detail: self, animate: false)
            }
        }
        isInputAllowed = useState == .normal
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        var items = [UIFocusEnvironment]()
        if let item = lastFocusedItem {
            items.append(item)
        }
        if !items.contains(where: { $0 === listView }) {
            items.append(listView)
        }
        if !items.contains(where: { $0 === inputTextView }) {
            items.append(inputTextView)
        }
        return items
    }
    override var canBecomeFirstResponder: Bool { true }
    override var canResignFirstResponder: Bool { true }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        guard let nextFocusedItem = context.nextFocusedItem else {
            if let ip = listView.lastRowIndexPath {
//                listView.selectRow(at: ip, animated: true, scrollPosition: .middle)
//                lastFocusedItem = listView.cellForRow(at: ip)
//                setNeedsFocusUpdate()
//                Current.focusLog.debug("Detail update focus to last cell.")
            } else {
                dispatch_async_on_main {
                    self.handleLeftArrow()
                }
                Current.focusLog.debug("Detail update focus to side bar.")
            }
            return
        }
        Current.focusLog.debug("Detail update focus to: \(nextFocusedItem).")
        if nextFocusedItem.isChildren(of: self) {
            lastFocusedItem = nextFocusedItem
        }
        ApplicationMenu.sendbyKey = inputSendby
    }

    override func becomeFirstResponder() -> Bool {
        ApplicationMenu.setNeedsRevalidate()
        return super.becomeFirstResponder()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(onSend) {
            return isInputAllowed
        }
        return super.responds(to: aSelector)
    }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        commands.append(
            UIKeyCommand(action: #selector(handleLeftArrow), input: UIKeyCommand.inputLeftArrow)
        )
        return commands
    }

    @objc func handleLeftArrow() {
        RootViewController.of(view)?.focusSidebar()
    }

    @IBAction func focusInputBox(_ sender: Any) {
        _ = inputTextView.becomeFirstResponder()
    }

    func didBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(onSelectionLabelEdit), name: .selectableLabelOnEdit, object: nil)
        item.loadDraft(toView: inputTextView)
        ApplicationMenu.sendbyKey = inputSendby
    }

    func didBecomeHidden() {
        NotificationCenter.default.removeObserver(self, name: .selectableLabelOnEdit, object: nil)
        saveDraft()
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

    @IBAction private func gotoAppIntegrationHelp(_ sender: Any) {
        URL.open(link: L.Guide.interCommunicationLink)
    }

    @IBAction private func onCopyJSBookmark(_ sender: Any) {
        var comp = URLComponents()
        comp.scheme = Bundle.main.bundleIdentifier ?? "b9chatai"
        comp.host = "send"
        comp.queryItems = [
            .init(name: "id", value: item.id),
            .init(name: "text", value: "")
        ]
        let urlPart = comp.url?.absoluteString ?? ""
        UIPasteboard.general.string = "javascript:a=\"\(urlPart)\"+encodeURIComponent(window.getSelection().toString());window.location.href=a"
    }

    func conversationListStateChanged(_ item: Conversation) {
        if navigationItem.title != item.title {
            navigationItem.title = item.title
            view.window?.windowScene?.title = item.title
        }
    }
}

// MARK: -

extension ConversationDetailViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIFocusSystem.focusSystem(for: tableView)?.requestFocusUpdate(to: cell)
        }
        needsItemSelectionUpdate.set()
    }

    @objc func updateItemSelectionChange() {
        let selectedItems = listDataSource.selectedItems
        let noItem = selectedItems.isEmpty
        if inputActionContainer.isHidden != noItem {
            inputActionContainer.isHidden = noItem
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        if let firstItem = selectedItems.first, selectedItems.count == 1 {
            tellMoreButton.isHidden = firstItem.role == .me
        }

        if replySelectionButton.isSelected {
            inputReplyItems = listDataSource.selectedItems
            updateForInputReplyItems()
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

//    var isLastCellVisible: Bool {
//        // fix: 空列表
//        let lastRow = listView.numberOfRows(inSection: 0) - 1
//        return listView.indexPathsForVisibleRows?.contains(IndexPath(row: lastRow, section: 0)) == true
//    }

//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == listView {
//            isReadingHistory = !isLastCellVisible
//        }
//    }

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

// MARK: - Reply Selection
extension ConversationDetailViewController {

    @IBAction func toggleLastReply(_ sender: Any) {
        guard let lastIndexPath = listView.lastRowIndexPath,
              let lastItem = listDataSource.item(at: lastIndexPath) else {
            return
        }
        if inputReplyItems == [lastItem] {
            onDismissReplySelection(self)
        } else {
            replySelectionButton.isSelected = true
            listView.selectRow(at: lastIndexPath, animated: true, scrollPosition: .middle)
            tableView(listView, didSelectRowAt: lastIndexPath)
        }
    }

    @IBAction private func onReplySelectionConfirm() {
        if replySelectionButton.isSelected {
            listDataSource.scrollTo(
                item: inputReplyItems?.last,
                selection: true,
                animated: true)
            return
        }
        replySelectionButton.isSelected = true
        inputReplyItems = listDataSource.selectedItems
        updateForInputReplyItems()
    }

    private func updateForInputReplyItems() {
        inputActionStateLabel.text = nil
        if let last = inputReplyItems?.last {
            let title = L.Chat.Reply.selectionContinue(last.replySelectionTitle)
            replySelectionButton.setTitle(title, for: .selected)
            last.hasNext { [weak self] item, hasNext in
                guard let sf = self,
                      item === last else { return }
                if hasNext {
                    sf.inputActionStateLabel.text = L.Chat.Reply.dropContextWarning
                }
            }
        } else {
            replySelectionButton.isSelected = false
        }
    }

    /// 取消选中，再点取消列表选中
    @IBAction private func onDismissReplySelection(_ sender: Any) {
        if replySelectionButton.isSelected {
            replySelectionButton.isSelected = false
            inputReplyItems = nil
            updateForInputReplyItems()
        } else {
            UIFocusSystem.focusSystem(for: self)?.requestFocusUpdate(to: listView)
            listView.deselectRows(false)
            needsItemSelectionUpdate.set()
        }
    }

    func deselectReplyItemForListChangeIfNeeded() {
        guard let oldItems = inputReplyItems else { return }
        let newReplyItems = oldItems.filter { listDataSource.indexPath(of: $0) != nil }
        if newReplyItems == oldItems { return }
        if newReplyItems.isEmpty {
            onDismissReplySelection(self)
        } else {
            updateForInputReplyItems()
        }
    }
}

// MARK: - Input

extension ConversationDetailViewController: UITextViewDelegate {

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        sendbyTrackIsShiftPressed = event?.modifierFlags == .shift
        super.pressesBegan(presses, with: event)
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        sendbyTrackIsShiftPressed = false
        super.pressesEnded(presses, with: event)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if inputSendby == .shift {
                if sendbyTrackIsShiftPressed {
                    onSend()
                    return false
                }
            } else if inputSendby == .enter {
                if !sendbyTrackIsShiftPressed {
                    onSend()
                    return false
                }
            }
        }

        AppLog().debug("Textview change text: \(text)")
        if text == "\t" {
            textView.resignFirstResponder()
            handleLeftArrow()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        setInputExpand(false, animate: true)
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

    func setInputExpand(_ expand: Bool, animate: Bool) {
        if isInputExpand == expand { return }
        isInputExpand = expand
        UIView.animate(withDuration: 0.3, delay: 0, animated: animate, beforeAnimations: nil, animations: { [self] in
            inputTextView.font = UIFont.preferredFont(forTextStyle: expand ? .callout : .body)
            inputTextHeight.constant = expand ? 300 : 46
            view.layoutIfNeeded()
        })
    }

    private func updateSendButton(sendby: Sendby) {
        inputSendButton.text = sendby.symbolDescription
    }

    @IBAction func onSend() {
        if let text = inputTextView.text.trimmed() {
            item.send(text: text, reply: inputReplyItems?.last)
            listDataSource.shouldUpdateSelectionForNewMessageInContext = true
        }
        inputTextView.text = nil
        setInputExpand(false, animate: true)
    }

    @IBAction private func onTellMore(_ sender: Any) {
        tellMoreButton.isEnabled = false
        if let item = listDataSource.selectedItems.first {
            Message.continueMessage(item)
        }
        dispatch_after_seconds(1) { [weak self] in
            self?.tellMoreButton.isEnabled = true
        }
    }

    private func saveDraft() {
        let text = inputTextView.draftText?.trimmed()
        var config = item.chatConfig
        if config.draft != text {
            config.draft = text
            AppLog().debug("Draft> Save: \(text ?? "nil").")
            item.chatConfig = config
        }
    }
}
