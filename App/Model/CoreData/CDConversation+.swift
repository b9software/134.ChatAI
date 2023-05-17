//
//  CDConversation+.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

public extension CDConversation {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID().uuidString
        createTime = .current
        lastTime = createTime
    }

    override func awakeFromFetch() {
        super.awakeFromFetch()
        if id == nil {
            id = UUID().uuidString
            AppLog().warning("CD> Add missing id to a CDConversation.")
        }
    }
}

extension CDConversation {
    static let titleKey = #keyPath(CDConversation.title)
    static let lastTimeKey = #keyPath(CDConversation.lastTime)
    static let createTimeKey = #keyPath(CDConversation.createTime)
    static let archiveTimeKey = #keyPath(CDConversation.archiveTime)
    static let deleteTimeKey = #keyPath(CDConversation.deleteTime)

    static var debugRequest: NSFetchRequest<CDConversation> {
        let request = fetchRequest()
        request.propertiesToFetch = [
            "id", titleKey,
            createTimeKey, lastTimeKey, archiveTimeKey, deleteTimeKey
        ]
        return request
    }

    static func request(id: StringID) -> NSFetchRequest<CDConversation> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }

    static var chatListRequest: NSFetchRequest<CDConversation> {
        let request = fetchRequest()
        var sortDescriptors = [
            NSSortDescriptor(key: createTimeKey, ascending: false),
        ]
        if Current.defualts.conversationSortBy == .lastTime {
            sortDescriptors.insert(NSSortDescriptor(key: lastTimeKey, ascending: false), at: 0)
        }
        request.sortDescriptors = sortDescriptors
        request.predicate = NSPredicate(
            format: "%K == nil AND %K == nil",
            archiveTimeKey, deleteTimeKey
        )
        request.fetchLimit = 100
        return request
    }

    static var archivedRequest: NSFetchRequest<CDConversation> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: archiveTimeKey, ascending: false),
        ]
        request.predicate = NSPredicate(format: "%K != nil AND %K == nil", archiveTimeKey, deleteTimeKey)
        request.fetchLimit = 100
        return request
    }

    static var deletedRequest: NSFetchRequest<CDConversation> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: deleteTimeKey, ascending: false),
        ]
        request.predicate = NSPredicate(format: "%K != nil", deleteTimeKey)
        request.fetchLimit = 100
        return request
    }
}

extension CDConversation {
    func isNewIDAvailable(newID: String) async -> Bool {
        await Current.database.read { ctx in
            if newID == self.id {
                return true
            }
            let fetchResult = try? ctx.fetch(Self.request(id: newID))
            return fetchResult?.isEmpty ?? false
        }
    }

    func loadChatConfig() -> ChatConfig? {
        guard let data = cSetting else { return nil }
        do {
            return try ChatConfig.decode(data)
        } catch {
            AppLog().critical("Unable decode ChatConfig: \(error)")
            return nil
        }
    }

    func loadEngineConfig() -> EngineConfig? {
        guard let data = eSetting else { return nil }
        do {
            return try EngineConfig.decode(data)
        } catch {
            AppLog().critical("Unable decode EngineConfig: \(error)")
            return nil
        }
    }
}
