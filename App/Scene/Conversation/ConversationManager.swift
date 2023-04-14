//
//  ConversationManager.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import B9MulticastDelegate
import CoreData

class ConversationManager: NSObject {
    let delegates = MulticastDelegate<ConversationListUpdating>()
    let context: NSManagedObjectContext

    override init() {
        context = Current.database.backgroundContext
        super.init()
        setup()
    }

    func setup() {
        listController = NSFetchedResultsController(fetchRequest: CDConversation.chatListRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "cn.chat")
        listController.delegate = self
        archivedController = NSFetchedResultsController(fetchRequest: CDConversation.archivedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "cn.archive")
        archivedController.delegate = self
        deletedController = NSFetchedResultsController(fetchRequest: CDConversation.deletedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "cn.delete")
        deletedController.delegate = self
        context.perform { [self] in
            Do.try {
                try listController.performFetch()
                try archivedController.performFetch()
                try deletedController.performFetch()
            }
            forceUpdateList()
            hasArchived = archivedController.fetchedObjects?.isNotEmpty ?? false
            hasDeleted = deletedController.fetchedObjects?.isNotEmpty ?? false
            AppLog().info("CM> Init status")
        }
    }

    var listItems = [Conversation]()
    private var listController: NSFetchedResultsController<CDConversation>!
    private var archivedController: NSFetchedResultsController<CDConversation>!
    private var deletedController: NSFetchedResultsController<CDConversation>!

    private(set) var hasArchived = false {
        didSet {
            if oldValue == hasArchived { return }
            Task { @MainActor in
                delegates.invoke { $0.conversations(self, hasArchived: hasArchived) }
            }
        }
    }
    private(set) var hasDeleted = false {
        didSet {
            if oldValue == hasDeleted { return }
            Task { @MainActor in
                delegates.invoke { $0.conversations(self, hasDeleted: hasDeleted) }
            }
        }
    }

    func createNew() {
        context.perform {
            _ = CDConversation(context: self.context)
        }
    }

    private var needsReloadListAfterChangeEnd = false
    private lazy var needsNoticeListChange = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.delegates.invoke {
            $0.conversations(sf, listUpdated: sf.listItems)
        }
        AppLog().debug("CM> Did notice list change")
    })
}

// MARK: - Change Tracking

extension ConversationManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == listController {
            AppLog().debug("CM> list change \(type)")
            switch type {
            case .insert:
                if let idx = newIndexPath?.row,
                   let entity = anObject as? CDConversation {
                    let item = Conversation.from(entity: entity)
                    listItems.insert(item, at: idx)
                    needsNoticeListChange.set()
                    AppLog().debug("CM> Did insert list item: \(entity.objectID).")
                }
            case .delete:
                if let idx = indexPath?.row,
                   let entity = anObject as? CDConversation {
                    handleListDelete(idx: idx, entity: entity)
                }
            case .move:
                needsReloadListAfterChangeEnd = true
            default:
                break
            }
        } else if controller == archivedController {
            handleArchivedChanges(type)
        } else if controller == deletedController {
            handleDeletedChanges(type)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == listController {
            if needsReloadListAfterChangeEnd {
                AppLog().debug("CM> Reload list after change end.")
                needsReloadListAfterChangeEnd = false
                forceUpdateList()
            }
        }
    }

    private func forceUpdateList() {
        listItems = (listController.fetchedObjects ?? []).map(Conversation.from(entity:))
        needsNoticeListChange.set(reschedule: true)
        AppLog().debug("CM> Updated list: \(listItems)")
    }

    private func handleListDelete(idx: Int, entity: CDConversation) {
        if let item = listItems.element(at: idx),
           item.id == entity.id {
            listItems.remove(at: idx)
            needsNoticeListChange.set()
            AppLog().debug("CM> Did delete list item: \(entity.objectID).")
        } else {
            // 批量删除时会连续调用，但是序号是快照时的，上面有删除后就对不上了
            needsReloadListAfterChangeEnd = true
            AppLog().debug("CM> Needs force reload list.")
        }
    }

    private func handleArchivedChanges(_ type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            hasArchived = true
        case .delete:
            hasArchived = archivedController.fetchedObjects?.isNotEmpty ?? false
        default:
            return
        }
        AppLog().debug("CM> archived change \(type)")
    }

    private func handleDeletedChanges(_ type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            hasDeleted = true
        case .delete:
            hasDeleted = deletedController.fetchedObjects?.isNotEmpty ?? false
        default:
            return
        }
        AppLog().debug("CM> deleted change \(type)")
    }
}

protocol ConversationListUpdating {
    func conversations(_ manager: ConversationManager, listUpdated: [Conversation])
    func conversations(_ manager: ConversationManager, hasArchived: Bool)
    func conversations(_ manager: ConversationManager, hasDeleted: Bool)
}

extension ConversationListUpdating {
    func conversations(_ manager: ConversationManager, listUpdated: [Conversation]) {}
    func conversations(_ manager: ConversationManager, hasArchived: Bool) {}
    func conversations(_ manager: ConversationManager, hasDeleted: Bool) {}
}
