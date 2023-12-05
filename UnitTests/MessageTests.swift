//
//  MessageTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import AppFramework
import XCTest

// swiftlint:disable blanket_disable_command
// swiftlint:disable identifier_name function_body_length closure_body_length type_body_length
// swiftlint:enable blanket_disable_command

class MessageTests: TestCase {
    override class var mockResetPoint: TestCase.ResetPoint { [ .tearDown] }

    override class var coverUserDefaultsKeys: [String] {
        [
            "debugMessageTime",
            "debugMessageSkipSending",
        ]
    }

    override func tearDown() {
        super.tearDown()
        restoreNow()
    }

    func testPrepareSendData() async throws {
        let chatEntity = await Current.database.read {
            $0.assertIsFresh()
            let entity = CDConversation(context: $0)
            assert(entity.id != nil)
            assert(entity.createTime != nil)
            return entity
        }
        let chat = await Current.database.read { _ in
            Conversation.from(entity: chatEntity)
        }
        await Current.database.read { _ in
            chat.send(text: "m1", reply: nil)
        }
        noBlockingWait(0.01)
        let reply1st = try await Current.database.read { [self] ctx in
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

    func testInsertEnd() async throws {
        let createResult = await Current.database.read { ctx in
            ctx.assertIsFresh()

            let chat = CDConversation(context: ctx)
            let items = ctx.createMessages(
                in: chat,
                time: Date("2020-02-20 01:00:00"),
                [
                    .init(create: Date("2020-02-20 01:00:00"), text: "m1"),
                    .init(create: Date("2020-02-20 01:00:00"), text: "m2", role: .assistant),
                    .init(create: Date("2020-02-20 02:00:00"), text: nil, role: .assistant, state: .error),
                    .init(create: Date("2020-02-20 02:00:00"), text: "m4"),
                ]
            )
            ctx.trySave()
            return items
        }

        let m1 = createResult[0]
        let m2 = createResult[1]
        let m3 = createResult[2]
        let m4 = createResult[3]

        setNow("2020-02-20 03:00:00")

        let m6 = try await Current.database.read { [self] ctx in
            let chatID = m1.conversation!.objectID
            let entity = try CDMessage.createEntities(ctx, conversation: chatID, reply: m4.objectID).0
            entity.text = "my"
            entity.mType = .text
            ctx.trySave()

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
            return m6
        }

        let sendItems = try await m6.buildContext()
        assertEqual(sendItems, [
            .init(role: .user, content: "m1"),
            .init(role: .assistant, content: "m2"),
            .init(role: .user, content: "m4"),
            .init(role: .user, content: "my"),
        ])
    }

    func testCreateNew() async throws {
        let firstItems = try await Current.database.read { [self] ctx in
            ctx.assertIsFresh()

            let chat = CDConversation(context: ctx)
            let m1 = try CDMessage.createEntities(ctx, conversation: chat.objectID, reply: nil).0
            m1.text = "my"
            m1.mType = .text
            try ctx.save()

            assertEqual(m1.debugChildTexts, ["nil"])
            assertEqual(m1.linkChildTexts(ctx), ["nil"])
            var items = try ctx.fetch(CDMessage.childRequest(parent: m1))
            items.insert(m1, at: 0)
            assertEqual(items.count, 2)
            return items
        }

        let send1 = try await firstItems.last!.buildContext()
        assertEqual(send1, [
            .init(role: .user, content: "my"),
        ])
    }

    func testInsertBegin() async throws {
        let firstItems = try await Current.database.read { [self] ctx in
            ctx.assertIsFresh()

            let chat = CDConversation(context: ctx)
            let firstItems = ctx.createMessages(
                in: chat,
                time: Date("2020-02-20 01:00:00"),
                [
                    .init(create: Date("2020-02-20 01:00:00"), text: "m1"),
                    .init(create: Date("2020-02-20 01:00:00"), text: "m2"),
                ]
            )

            let m1 = firstItems[0]
            setNow("2020-02-20 03:00:00")

            let chatID = m1.conversation!.objectID
            assertEqual(m1.debugChildTexts, ["m2"])
            assertEqual(m1.linkChildTexts(ctx), ["m2"])
            let my1 = try CDMessage.createEntities(ctx, conversation: chatID, reply: m1.objectID).0
            my1.text = "my1"
            my1.mType = .text
            try ctx.save()

            assertEqual(m1.debugChildTexts, ["my1", "nil"])
            assertEqual(m1.linkChildTexts(ctx), ["my1", "nil"])
            var items = try ctx.fetch(CDMessage.childRequest(parent: m1))
            items.insert(m1, at: 0)
            assertEqual(items.count, 3)
            return items
        }

        let send1 = try await firstItems.last!.buildContext()
        assertEqual(send1, [
            .init(role: .user, content: "m1"),
            .init(role: .user, content: "my1"),
        ])

        let secondItems = try await Current.database.read { [self] ctx in
            let parent = firstItems[0]
            let chatID = parent.conversation!.objectID

            assertEqual(parent.text, "m1")
            let my = try CDMessage.createEntities(ctx, conversation: chatID, reply: parent.objectID).0
            my.text = "my2"
            my.mType = .text
            try ctx.save()

            let items = try ctx.fetch(CDMessage.fetchRequest())
            assertEqual(items.count, 3)
            return items
        }

        let send2 = try await secondItems.last!.buildContext()
        assertEqual(send2, [
            .init(role: .user, content: "m1"),
            .init(role: .user, content: "my2"),
        ])
    }

    func testInsertMiddle() async throws {
        let m6 = try await Current.database.read { [self] ctx in
            ctx.assertIsFresh()

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
            let entity = try CDMessage.createEntities(ctx, conversation: chat.objectID, reply: m2.objectID).0
            entity.text = "my"
            entity.mType = .text

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
            return m6
        }

        let sendItems = try await m6.buildContext()
        assertEqual(sendItems, [
            .init(role: .user, content: "m1"),
            .init(role: .assistant, content: "m2"),
            .init(role: .user, content: "my"),
        ])
    }
}
