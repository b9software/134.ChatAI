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
        request.sortDescriptors = [
            NSSortDescriptor(key: createTimeKey, ascending: false),
        ]
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
    func isNewIDAvailable(newID: String) -> Bool {
        read { this, ctx in
            if newID == this.id {
                return true
            }
            return try ctx.fetch(Self.request(id: newID)).first == nil
        } ?? false
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
