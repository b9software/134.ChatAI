//
//  MessageBuildTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class MessageBuildTests: TestCase {
    override class var mockResetPoint: TestCase.ResetPoint { [.tearDownClass] }

    let database = Current.database

    override func tearDown() {
        super.tearDown()
        Mocked.reset()
    }

    func test() async throws {
        defer { database.backgroundContext.reset() }
        let chatEntity = await database.write {
            let entity = CDConversation(context: $0)
            assert(entity.id != nil)
            assert(entity.createTime != nil)
            return entity
        }
        debugPrint("enmity", chatEntity)
        let chat = await database.read { _ in
            Conversation.from(entity: chatEntity)
        }
        debugPrint("item", chat)
        await database.write { _ in
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
}
