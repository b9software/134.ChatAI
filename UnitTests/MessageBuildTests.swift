//
//  MessageBuildTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

// swiftlint:disable identifier_name

class MessageBuildTests: TestCase {
    override class var mockResetPoint: TestCase.ResetPoint { [.tearDown] }

    let database = Current.database

    func testPrepareSendData() async throws {
        let chatEntity = await database.read {
            let entity = CDConversation(context: $0)
            assert(entity.id != nil)
            assert(entity.createTime != nil)
            return entity
        }
        let chat = await database.read { _ in
            Conversation.from(entity: chatEntity)
        }
        await database.read { _ in
            chat.send(text: "m1", reply: nil)
        }
        noBlockingWait(0.01)
        let reply1st = try await database.read { [self] ctx in
            let entities = try ctx.fetch(CDMessage.fetchRequest())
            guard entities.count == 2 else {
                throw AppError.message("Should have two messages")
            }
            let mine = entities.first(where: { $0.mRole == .me })!
            let reply = entities.first(where: { $0.mRole == .assistant })!

            assertEqual(mine.mRole, .me)
            assertEqual(mine.mState, .normal)
            assertEqual(mine.text, "m1")
            assertEqual(mine.child?.allObjects as? [CDMessage], [reply])
            assertEqual(mine.parent, nil)

            assertEqual(reply.mRole, .assistant)
            assertEqual(reply.mState, .pend)
            assertEqual(reply.parent, mine)
            return reply
        }

        let sendItems = try await reply1st.buildContext()
        assertEqual(sendItems, [.init(role: .user, content: "m1")])
    }

    func testInsertEnd() throws {
        let ctx = database.container.viewContext
        ctx.assertIsFresh()
        defer {
            restoreNow()
        }

        let chat = CDConversation(context: ctx)
        setNow("2020-02-20 01:00:00")
        let m1 = CDMessage(context: ctx)
        let m2 = CDMessage(context: ctx)
        setNow("2020-02-20 02:00:00")
        let m3 = CDMessage(context: ctx)
        let m4 = CDMessage(context: ctx)

        for item in [m1, m2, m3, m4] {
            item.mType = .text
            item.mRole = .me
            item.mState = .pend
            item.conversation = chat
            item.parent = m1
        }
        m1.parent = nil
        m1.prev = m2.uid
        m1.next = m4.uid
        m1.text = "m1"
        m2.text = "m2"
        m2.mRole = .assistant
        m2.prev = m1.uid
        m2.next = m3.uid
        m3.mState = .error
        m3.mRole = .assistant
        m3.prev = m2.uid
        m3.next = m4.uid
        m4.text = "m4"
        m4.prev = m3.uid

        ctx.trySave()
        setNow("2020-02-20 03:00:00")

        // Reply at the end
        let exp = expectation(description: "Task end")
        Task {
            try await Current.database.read {
                $0.refreshAllObjects()
                let entity = try CDMessage.createEntities($0, conversation: chat.objectID, reply: m4.objectID)
                entity.text = "my"
                entity.mType = .text
                $0.trySave()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        ctx.refreshAllObjects()

        // Then: We should have all six items
        let newItems = try ctx.fetch(CDMessage.fetchRequest())
        assertEqual(newItems.count, 6)
        guard let m5 = newItems.first(where: { $0.uid == m4.next }) else {
            throw AppError.message("m4 next should point to m5")
        }
        guard let m6 = newItems.first(where: { $0.uid == m5.next }) else {
            throw AppError.message("m5 next should point to m6")
        }

        let items = [m1, m2, m3, m4, m5, m6]
        for item in items {
            XCTAssertNotNil(item.time)
        }
        for item in [m2, m3, m4, m5, m6] {
            assertEqual(item.parent, m1)
        }
        assertEqual(m1.next, m6.uid)
        assertEqual(m1.prev, m2.uid)
        assertEqual(m2.prev, m1.uid)
        assertEqual(m2.next, m3.uid)
        assertEqual(m3.prev, m2.uid)
        assertEqual(m3.next, m4.uid)
        assertEqual(m4.prev, m3.uid)
        assertEqual(m4.next, m5.uid)
        assertEqual(m5.prev, m4.uid)
        assertEqual(m5.next, m6.uid)
        assertEqual(m6.prev, m5.uid)
        assertEqual(m6.next, nil)
        debugPrint(items)

        let buildExp = expectation(description: "build end")
        Task {
            let sendItems = try await m6.buildContext()
            assertEqual(sendItems, [
                .init(role: .user, content: "m1"),
                .init(role: .assistant, content: "m2"),
                .init(role: .user, content: "m4"),
                .init(role: .user, content: "my"),
            ])
            buildExp.fulfill()
        }
        wait(for: [buildExp], timeout: 10)
    }

    func testInsertMiddle() throws {
        let ctx = database.container.viewContext
        ctx.assertIsFresh()
        defer {
            restoreNow()
        }

        let chat = CDConversation(context: ctx)
        setNow("2020-02-20 01:00:00")
        let m1 = CDMessage(context: ctx)
        let m2 = CDMessage(context: ctx)
        setNow("2020-02-20 02:00:00")
        let m3 = CDMessage(context: ctx)
        let m4 = CDMessage(context: ctx)

        for item in [m1, m2, m3, m4] {
            item.mType = .text
            item.mRole = .me
            item.mState = .pend
            item.conversation = chat
            item.parent = m1
        }
        m1.parent = nil
        m1.prev = m2.uid
        m1.next = m4.uid
        m1.text = "m1"
        m2.text = "m2"
        m2.mRole = .assistant
        m2.prev = m1.uid
        m2.next = m3.uid
        m3.mState = .error
        m3.mRole = .assistant
        m3.prev = m2.uid
        m3.next = m4.uid
        m4.text = "m4"
        m4.prev = m3.uid

        ctx.trySave()
        setNow("2020-02-20 03:00:00")

        // Reply at middle
        let exp = expectation(description: "Task end")
        Task {
            try await Current.database.read {
                $0.refreshAllObjects()
                let entity = try CDMessage.createEntities($0, conversation: chat.objectID, reply: m2.objectID)
                entity.text = "my"
                entity.mType = .text
                $0.trySave()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        ctx.refreshAllObjects()

        // Then: We should have all six items
        let newItems = try ctx.fetch(CDMessage.fetchRequest())
        assertEqual(newItems.count, 4)
        guard let m5 = newItems.first(where: { $0.uid == m2.next }) else {
            throw AppError.message("m2 next should point to m5")
        }
        guard let m6 = newItems.first(where: { $0.uid == m5.next }) else {
            throw AppError.message("m5 next should point to m6")
        }

        let items = [m1, m2, m5, m6]
        for item in items {
            XCTAssertNotNil(item.time)
        }
        for item in [m2, m5, m6] {
            assertEqual(item.parent, m1)
        }
        assertEqual(m1.next, m6.uid)
        assertEqual(m1.prev, m2.uid)
        assertEqual(m2.prev, m1.uid)
        assertEqual(m2.next, m5.uid)
        assertEqual(m5.prev, m2.uid)
        assertEqual(m5.next, m6.uid)
        assertEqual(m6.prev, m5.uid)
        assertEqual(m6.next, nil)
        debugPrint(items)

        let buildExp = expectation(description: "build end")
        Task {
            let sendItems = try await m6.buildContext()
            assertEqual(sendItems, [
                .init(role: .user, content: "m1"),
                .init(role: .assistant, content: "m2"),
                .init(role: .user, content: "my"),
            ])
            buildExp.fulfill()
        }
        wait(for: [buildExp], timeout: 10)
    }
}
