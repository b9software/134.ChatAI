//
//  ConversationListDisplayer.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/21.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class ConversationListDisplayer: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .conversation }
}

/// 只加了选中删除，主题色随焦点变化
class ConversationListView: UITableView {
    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        commands.append(
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(delete))
        )
        return commands
    }

    override func becomeFirstResponder() -> Bool {
        defer { updateTintColor() }
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        defer { updateTintColor() }
        return super.resignFirstResponder()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateTintColor()
    }

    private func updateTintColor() {
        tintColor = isFirstResponder ? nil : .systemGray
    }
}

class ChatArchivedListController:
    UIViewController,
    StoryboardCreation,
    UITableViewDelegate
{
    static var storyboardID: StoryboardID { .conversation }

    private lazy var listDataSource = CDFetchTableViewDataSource<Conversation, CDConversation>(tableView: listView, transformer: Conversation.from(entity:))
    @IBOutlet private weak var listView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        listDataSource.fetchRequest = CDConversation.archivedRequest
    }

    override func delete(_ sender: Any?) {
        listView.indexPathsForSelectedRows?.forEach { ip in
            guard let item = listDataSource.item(at: ip) else {
                assert(false)
                return
            }
            item.delete()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = listDataSource.item(at: indexPath),
              let parent = parent as? SidebarViewController else {
            assert(false)
            return
        }
        parent.select(conversation: item, in: tableView)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            let restoreCommand = UIKeyCommand(
                title: L.Chat.unArchive,
                action: #selector(self.restoreFromMenu(sender:)),
                input: "r",
                propertyList: indexPath.row)
            let deleteCommand = UIKeyCommand(
                title: L.Menu.delete,
                action: #selector(self.deleteFromMenu(sender:)),
                input: "d",
                propertyList: indexPath.row)
            return UIMenu(children: [restoreCommand, deleteCommand])
        })
    }

    @objc
    func restoreFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let item = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        item.unarchive()
    }

    @objc
    func deleteFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let item = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        item.delete()
    }
}

class ChatDeletedListController:
    UIViewController,
    StoryboardCreation,
    UITableViewDelegate
{
    static var storyboardID: StoryboardID { .conversation }

    private lazy var listDataSource = CDFetchTableViewDataSource<Conversation, CDConversation>(tableView: listView, transformer: Conversation.from(entity:))
    @IBOutlet private weak var listView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        listDataSource.fetchRequest = CDConversation.deletedRequest
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = listDataSource.item(at: indexPath),
              let parent = parent as? SidebarViewController else {
            assert(false)
            return
        }
        parent.select(conversation: item, in: tableView)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            let restoreCommand = UIKeyCommand(
                title: L.Chat.deleteRestore,
                action: #selector(self.restoreFromMenu(sender:)),
                input: "r",
                propertyList: indexPath.row)
            let deleteCommand = UIKeyCommand(
                title: L.Chat.deleteNow,
                action: #selector(self.deleteNowFromMenu(sender:)),
                input: "d",
                propertyList: indexPath.row)
            return UIMenu(children: [restoreCommand, deleteCommand])
        })
    }

    @objc
    func restoreFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let item = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        Current.database.save { _ in
            item.entity.deleteTime = nil
        }
    }

    @objc
    func deleteNowFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let item = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        Current.database.save { ctx in
            ctx.delete(item.entity)
        }
    }
}
