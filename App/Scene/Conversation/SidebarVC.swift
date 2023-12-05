//
//  SidebarVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppFramework
import B9Action
import UIKit

class SidebarViewController: UIViewController, ConversationListUpdating {

    lazy var manager: ConversationManager = {
        let core = Current.conversationManager
        core.delegates.add(self)
        return core
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        listView.allowsFocus = true
        setupCommandButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conversations(manager, listUpdated: manager.listItems)
        conversations(manager, hasArchived: manager.hasArchived)
        conversations(manager, hasDeleted: manager.hasDeleted)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCommandButtonLayout()
    }

    private weak var selectedTableView: UITableView?

    private lazy var listDataSource = GeneralSingleSectionListDataSource<Conversation>(tableView: listView, cellProvider: UITableView.cellProvider(_:indexPath:object:))

    @IBOutlet private weak var listView: UITableView! {
        didSet { listView.dataSource = listDataSource }
    }

    @IBOutlet private weak var newChatButton: UIButton!
    @IBOutlet private weak var commandButtonLayout: UIStackView!
    @IBOutlet private weak var archiveButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var guideButton: UIButton!
    @IBOutlet private weak var settingButton: UIButton!
    @IBOutlet private weak var panelContainer: UIView!
    private var archiveListController: UIViewController?
    private var deleteListController: UIViewController?
    private lazy var needsReleaseListController = DelayAction(
        Action(target: self, selector: #selector(releaseListControllerIfNeeded)),
        delay: 10)

    private weak var lastFocusedItem: UIFocusEnvironment?
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        var items = [UIFocusEnvironment]()
        if let item = lastFocusedItem {
            items.append(item)
        }
        if !items.contains(where: { $0 === listView }) {
            items.append(listView)
        }
        return items
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        guard let nextFocusedItem = context.nextFocusedItem else {
            return
        }
        if nextFocusedItem.isChildren(of: self),
           (nextFocusedItem as? UIResponder)?.canBecomeFirstResponder == true {
            lastFocusedItem = nextFocusedItem
        }
    }
}

extension SidebarViewController {
    func onNavigatorStackChanged(_ navigator: UINavigationController) {
        var detailSelectedItem: Conversation?
        if let vc = navigator.visibleViewController as? ConversationDetailViewController,
           let item = vc.item {
            detailSelectedItem = item
        }
        if let item = detailSelectedItem {
            if listDataSource.selectedItems.contains(item) {
                return
            }
            listDataSource.selectedItems = [item]
        } else {
            if selectedTableView == listView {
                listView.setSelected(indexPaths: [], animated: true)
            }
        }
    }

    @IBAction func newConversation(_ sender: Any?) {
        if let button = sender as? UIControl {
            button.isEnabled = false
            dispatch_after_seconds(1) {
                button.isEnabled = true
            }
        }
        Current.conversationManager.createNew()
    }

    func conversations(_ manager: ConversationManager, listUpdated: [Conversation]) {
        listDataSource.update(listItems: listUpdated)
    }

    func select(conversation: Conversation, in table: UITableView) {
        if selectedTableView != table {
            if let old = selectedTableView {
                old.resignFirstResponder()
                old.deselectRows(true)
            }
            selectedTableView = table
        }
        RootViewController.of(view)?.gotoChatDetail(item: conversation)
    }

    private func setupCommandButtons() {
        archiveButton.setImage(Asset.Icon.xmark.image, for: .selected)
        archiveButton.setImage(archiveButton.configuration?.image, for: .normal)
        deleteButton.setImage(Asset.Icon.xmark.image, for: .selected)
        deleteButton.setImage(deleteButton.configuration?.image, for: .normal)
    }

    private func updateCommandButtonLayout() {
        let isCompact = traitCollection.verticalSizeClass == .compact
        let oldCompact = commandButtonLayout.axis == .horizontal
        if isCompact == oldCompact { return }
        commandButtonLayout.axis = isCompact ? .horizontal : .vertical
        if isCompact {
            commandButtonLayout.distribution = .fillEqually
            archiveButton.text = nil
            archiveButton.contentHorizontalAlignment = .center
            deleteButton.text = nil
            deleteButton.contentHorizontalAlignment = .center
            guideButton.text = nil
            guideButton.contentHorizontalAlignment = .center
            settingButton.text = nil
            settingButton.contentHorizontalAlignment = .center
        } else {
            commandButtonLayout.distribution = .fillEqually
            archiveButton.text = L.Chat.archived
            archiveButton.contentHorizontalAlignment = .leading
            deleteButton.text = L.Chat.deleted
            deleteButton.contentHorizontalAlignment = .leading
            guideButton.text = L.Menu.guide
            guideButton.contentHorizontalAlignment = .leading
            settingButton.text = L.Menu.setting
            settingButton.contentHorizontalAlignment = .leading
        }
    }
}

extension SidebarViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = listDataSource.item(at: indexPath) else {
            assert(false)
            return
        }
        select(conversation: item, in: tableView)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            let deleteCommand = UICommand(
                title: L.Menu.delete,
                action: #selector(self.deleteFromMenu(sender:)),
                propertyList: indexPath.row)
            let archiveCommand = UICommand(
                title: L.Menu.archive,
                action: #selector(self.archiveFromMenu(sender:)),
                propertyList: indexPath.row)
            return UIMenu(children: [archiveCommand, deleteCommand])
        })
    }

    @objc
    func archiveFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int else {
            assert(false)
            return
        }
        let ip = IndexPath(row: idx, section: 0)
        listDataSource.item(at: ip)?.archive()
    }

    @objc
    func deleteFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int else {
            assert(false)
            return
        }
        let ip = IndexPath(row: idx, section: 0)
        listDataSource.item(at: ip)?.delete()
    }

    override func delete(_ sender: Any?) {
        listView.indexPathsForSelectedRows?.forEach { ip in
            listDataSource.item(at: ip)?.delete()
        }
    }

    func conversations(_ manager: ConversationManager, hasArchived: Bool) {
        updateArchiveAndDeleteButton()
    }

    func conversations(_ manager: ConversationManager, hasDeleted: Bool) {
        updateArchiveAndDeleteButton()
    }

    private func updateArchiveAndDeleteButton() {
        archiveButton.isHidden = !manager.hasArchived && !archiveButton.isSelected
        deleteButton.isHidden = !manager.hasDeleted && !deleteButton.isSelected
    }

    @IBAction private func onToggleArchive(_ sender: Any) {
        archiveButton.isSelected.toggle()
        setArchiveListShown(archiveButton.isSelected, animated: true)
        setDeleteListShown(false, animated: true)
        updateArchiveAndDeleteButton()
    }

    @IBAction private func onToggleDelete(_ sender: Any) {
        deleteButton.isSelected.toggle()
        setDeleteListShown(deleteButton.isSelected, animated: true)
        setArchiveListShown(false, animated: true)
        updateArchiveAndDeleteButton()
    }

    private func prepareArchiveListController() -> UIViewController {
        let vc = archiveListController ?? {
            let vc = ChatArchivedListController.newFromStoryboard()
            archiveListController = vc
            addChild(vc)
            panelContainer.addSubview(vc.view, resizeOption: .fill)
            return vc
        }()
        vc.view.bringToFront()
        return vc
    }

    private func prepareDeleteListController() -> UIViewController {
        let vc = deleteListController ?? {
            let vc = ChatDeletedListController.newFromStoryboard()
            deleteListController = vc
            addChild(vc)
            panelContainer.addSubview(vc.view, resizeOption: .fill)
            return vc
        }()
        vc.view.bringToFront()
        return vc
    }

    @objc private func releaseListControllerIfNeeded() {
        if let vc = deleteListController,
            deleteButton.isHidden || !deleteButton.isSelected {
            vc.removeFromParentViewControllerAndView()
            deleteListController = nil
        }
        if let vc = archiveListController,
           archiveButton.isHidden || !archiveButton.isSelected {
            vc.removeFromParentViewControllerAndView()
            archiveListController = nil
        }
    }

    func setArchiveListShown(_ shown: Bool, animated: Bool) {
        archiveButton.isSelected = shown
        if shown {
            let vc = prepareArchiveListController()
            animate(panel: vc, shown: shown, animated: animated)
        } else {
            if let vc = archiveListController {
                animate(panel: vc, shown: shown, animated: animated)
                needsReleaseListController.set(reschedule: true)
            }
        }
    }

    func setDeleteListShown(_ shown: Bool, animated: Bool) {
        deleteButton.isSelected = shown
        if shown {
            let vc = prepareDeleteListController()
            animate(panel: vc, shown: shown, animated: animated)
        } else {
            if let vc = deleteListController {
                animate(panel: vc, shown: shown, animated: animated)
                needsReleaseListController.set(reschedule: true)
            }
        }
    }

    private func animate(panel vc: UIViewController, shown: Bool, animated: Bool) {
        var frame = vc.view.bounds
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animated: animated, beforeAnimations: {
            if shown {
                frame.origin.y = frame.height
                vc.view.frame = frame
                vc.view.alpha = 0
                vc.view.isHidden = false
            }
        }, animations: {
            vc.view.alpha = shown ? 1 : 0
            frame.origin.y = shown ? 0 : frame.height
            vc.view.frame = frame
        }, completion: { _ in
            vc.view.isHidden = !shown
            vc.view.alpha = 1
        })
    }
}
