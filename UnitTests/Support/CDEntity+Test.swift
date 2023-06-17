//
//  CDEntity+Test.swift
//  UnitTests
//
//  Created by Joseph Zhao on 2023/4/2.
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import CoreData
import XCTest

// swiftlint:disable force_try

extension NSManagedObjectContext {
    func createEngine(id: String) {
        performAndWait {
            let item = CDEngine(context: self)
            item.id = id
            try! self.save()
        }
    }

    func createConversation() -> CDConversation {
        performAndWait {
            let item = CDConversation(context: self)
            item.updateTime = .current
            try! self.save()
            return item
        }
    }

    struct MessageCreateInfo {
        var create: Date
        var text: String?
        var type: Message.MType = .text
        var role: Message.MRole = .me
        var state: Message.MState = .normal
    }

    func createMessages(in conversation: CDConversation, time: Date, _ children: [MessageCreateInfo]) -> [CDMessage] {
        var result = [CDMessage]()
        for cInfo in children {
            let entity = CDMessage(context: self)
            entity.time = time
            entity.createTime = cInfo.create
            entity.text = cInfo.text
            entity.mType = cInfo.type
            entity.mRole = cInfo.role
            entity.mState = cInfo.state
            entity.parent = result.first
            entity.conversation = conversation
            result.append(entity)
        }
        for (idx, entity) in result.enumerated() {
            entity.next = result.element(at: idx + 1)?.uid
            entity.prev = result.element(at: idx - 1)?.uid
        }
        result[0].prev = result[1].uid
        result[0].next = result.last?.uid
        return result
    }

    func assertIsFresh() {
        performAndWait {
            guard try! fetch(CDEngine.fetchRequest()).isEmpty,
                  try! fetch(CDConversation.fetchRequest()).isEmpty,
                  try! fetch(CDMessage.fetchRequest()).isEmpty else {
                XCTFail("Context is not fresh")
                return
            }
        }
    }

    func destroy() {
        performAndWait {
            try! fetch(CDConversation.fetchRequest()).forEach(delete(_:))
            try! fetch(CDMessage.fetchRequest()).forEach(delete(_:))
            try! fetch(CDEngine.fetchRequest()).forEach(delete(_:))
            try! save()
        }
    }
}

extension DBManager {

    func resetForTest() {
        container.viewContext.destroy()
        let ctx = backgroundContext
        ctx.performAndWait {
            ctx.destroy()
        }
    }
}

extension CDMessage {
    var debugChildTexts: [String] {
        child!.compactMap { ($0 as? CDMessage)?.text ?? "nil" }.sorted()
    }

    func linkChildTexts(_ ctx: NSManagedObjectContext) -> [String] {
        var result = [String]()
        var next = prev
        while let entity = Self.entity(uuid: next, context: ctx) {
            result.append(entity.text ?? "nil")
            next = entity.next
        }
        return result
    }
}

// swiftlint:enable force_try
