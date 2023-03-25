//
//  CoreDataTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class CoreDataTests: XCTestCase {
    let ctx = AppDatabase().container.viewContext

    override func tearDown() {
        super.tearDown()
        ctx.reset()
    }

    func testConversationMessageRelationshipDelete() throws {
        let conv = CDConversation(context: ctx)
        conv.type = "test"

        let msg1 = CDMessage(context: ctx)
        msg1.time = Date("2020-02-20 00:01:02")
        msg1.content = "test message 1"
        msg1.conversation = conv

        let msg2 = CDMessage(context: ctx)
        msg2.time = Date("2020-02-20 00:02:03")
        msg2.content = "test message 2"
        msg2.conversation = conv

        try ctx.save()

        var messages = try ctx.fetch(CDMessage.fetchRequest())
        XCTAssert(messages.count == 2)
        XCTAssert(conv.messages?.count == 2)

        ctx.delete(conv)

        messages = try ctx.fetch(CDMessage.fetchRequest())
        XCTAssert(messages.count == 0)
        XCTAssert(conv.messages?.count == 0)
    }
}
