//
//  CoreDataTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class CoreDataTests: TestCase {
    override class var mockResetPoint: TestCase.ResetPoint { [.setUpClass, .tearDownClass] }

    let ctx = Current.database.container.viewContext

    func testConversationMessageRelationshipDelete() throws {
        let conv = CDConversation(context: ctx)
        conv.type = "test"

        let msg1 = CDMessage(context: ctx)
        msg1.time = Date("2020-02-20 00:01:02")
        msg1.text = "test message 1"
        msg1.conversation = conv

        let msg2 = CDMessage(context: ctx)
        msg2.time = Date("2020-02-20 00:02:03")
        msg2.text = "test message 2"
        msg2.conversation = conv

        try ctx.save()

        var messages = try ctx.fetch(CDMessage.fetchRequest())
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(conv.messages?.count, 2)

        ctx.delete(conv)

        messages = try ctx.fetch(CDMessage.fetchRequest())
        XCTAssertEqual(messages.count, 0)
        XCTAssertEqual(conv.messages?.count, 0)
    }

    func testPredicateWithBadKey() throws {
        XCTExpectFailure()
        ctx.createEngine(id: "t1")
        let request = CDEngine.fetchRequest()
        request.predicate = NSPredicate(format: "bad-key = %@", "t1")
        _ = try ctx.fetch(request)
        XCTFail("Should not execute here")
    }
}
