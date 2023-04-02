//
//  CDEntityFetchTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class CDEntityFetchTests: TestCase {
    override class var mockResetPoint: TestCase.ResetPoint { [.setUpClass, .tearDownClass] }

    lazy var ctx = Current.database.viewContext

    func testEngineOperations() throws {
        var items = try ctx.fetch(CDEngine.listRequest)
        assertEqual(items, [])

        ctx.createEngine(id: "e1")
        ctx.createEngine(id: "e2")

        items = try ctx.fetch(CDEngine.listRequest)
        assertEqual(items.count, 2)

        let exp = expectation(description: "async")
        Task {
            let entity1 = CDEngine.fetch(id: "e1")
            XCTAssertNotNil(entity1)
            XCTAssertNil(CDEngine.fetch(id: "no-exist"))
            entity1?.delete()

            assertEqual(CDEngine.fetch(id: "e1"), nil)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.01)
    }

    func testConversationFetch() {
        let date1 = Date("2020-02-20 01:00:00")
        let date2 = Date("2020-02-20 11:00:00")

        let normal1 = ctx.createConversation()
        normal1.updateTime = date1
        let normal2 = ctx.createConversation()
        normal2.updateTime = date2

        let archived1 = ctx.createConversation()
        archived1.archiveTime = date1
        let archived2 = ctx.createConversation()
        archived2.archiveTime = date2

        let deleted1 = ctx.createConversation()
        deleted1.deleteTime = date1
        let deleted2 = ctx.createConversation()
        deleted2.deleteTime = date2

        assertEqual(
            try ctx.fetch(CDConversation.chatListRequest),
            [normal2, normal1])
        assertEqual(
            try ctx.fetch(CDConversation.archivedRequest),
            [archived2, archived1])
        assertEqual(
            try ctx.fetch(CDConversation.deletedRequest),
            [deleted2, deleted1])
    }
}
