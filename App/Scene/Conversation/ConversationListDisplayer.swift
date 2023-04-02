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

/// 只加了选中删除
class ConversationListView: UITableView {
    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        commands.append(
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(delete))
        )
        return commands
    }
}

class ChatArchivedListController:
    UIViewController,
    StoryboardCreation,
    UITableViewDelegate
{
    static var storyboardID: StoryboardID { .conversation }

    private lazy var listDataSource = CDFetchTableViewDataSource<CDConversation>()
    @IBOutlet private weak var listView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        listDataSource.tableView = listView
        listDataSource.fetchRequest = CDConversation.archivedRequest
    }

    override func delete(_ sender: Any?) {
        listView.indexPathsForSelectedRows?.forEach { ip in
            guard let entity = listDataSource.item(at: ip) else {
                assert(false)
                return
            }
            Conversation.from(entity: entity).delete()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entity = listDataSource.item(at: indexPath),
              let parent = parent as? SidebarViewController else {
            assert(false)
            return
        }
        let item = Conversation.from(entity: entity)
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
                title: L.Chat.deleteNow,
                action: #selector(self.deleteFromMenu(sender:)),
                input: "d",
                propertyList: indexPath.row)
            return UIMenu(children: [restoreCommand, deleteCommand])
        })
    }

    @objc
    func restoreFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let entity = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        Conversation.from(entity: entity).unarchive()
    }

    @objc
    func deleteFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let entity = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        Conversation.from(entity: entity).undelete()
    }
}

class ChatDeletedListController:
    UIViewController,
    StoryboardCreation,
    UITableViewDelegate
{
    static var storyboardID: StoryboardID { .conversation }

    private lazy var listDataSource = CDFetchTableViewDataSource<CDConversation>()
    @IBOutlet private weak var listView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        listDataSource.tableView = listView
        listDataSource.fetchRequest = CDConversation.deletedRequest
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entity = listDataSource.item(at: indexPath),
              let parent = parent as? SidebarViewController else {
            assert(false)
            return
        }
        let item = Conversation.from(entity: entity)
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
              let entity = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        entity.modify { this, _ in this.deleteTime = nil }
    }

    @objc
    func deleteNowFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int,
              let entity = listDataSource.item(at: IndexPath(row: idx, section: 0)) else {
            assert(false)
            return
        }
        entity.modify { $1.delete($0) }
    }
}
