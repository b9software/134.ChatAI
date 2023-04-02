//
//  ConversationManagerTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class ConversationManagerTests:
    TestCase,
    ConversationListUpdating
{
    override class var mockResetPoint: TestCase.ResetPoint { [.setUpClass, .tearDownClass] }

    func testArchivedAndDeleteTrack() {
        let manager = ConversationManager()
        manager.delegates.add(self)
        let ctx = manager.context
        ctx.assertIsFresh()
        defer { ctx.destroy() }

        let archived1 = ctx.createConversation()
        archived1.archiveTime = .current
        let deleted1 = ctx.createConversation()
        deleted1.deleteTime = .current
        assertEqual(manager.hasArchived, false)
        assertEqual(manager.hasDeleted, false)

        noBlockingWait(0.01)
        assertEqual(manager.hasArchived, true)
        assertEqual(manager.hasDeleted, true)

        ctx.delete(archived1)
        wait(for: [prepareWaitForHasArchivedChanged()], timeout: 0.1)
        assertEqual(manager.hasArchived, false)

        let archived2 = ctx.createConversation()
        archived2.archiveTime = .current
        wait(for: [prepareWaitForHasArchivedChanged()], timeout: 0.1)
        assertEqual(manager.hasArchived, true)

        ctx.delete(deleted1)
        wait(for: [prepareWaitForHasDeletedChanged()], timeout: 0.1)
        assertEqual(manager.hasDeleted, false)

        let deleted2 = ctx.createConversation()
        deleted2.deleteTime = .current
        wait(for: [prepareWaitForHasDeletedChanged()], timeout: 0.1)
        assertEqual(manager.hasDeleted, true)
    }

    func testListTrack() {
        let manager = ConversationManager()
        manager.delegates.add(self)
        let ctx = manager.context
        ctx.assertIsFresh()
        defer { ctx.destroy() }
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)

        let entity1 = ctx.createConversation()
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 1)

        let entity2 = ctx.createConversation()
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 2)

        ctx.delete(entity1)
        ctx.delete(entity2)
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 0)
    }

    func testListTrackInOtherContext() {
        let manager = ConversationManager()
        manager.delegates.add(self)
        let ctx = manager.context
        ctx.assertIsFresh()
        defer { ctx.destroy() }
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)

        let bgContext = Current.database.container.newBackgroundContext()
        bgContext.perform {
            _ = bgContext.createConversation()
        }
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 1)

        bgContext.perform {
            _ = bgContext.createConversation()
        }
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 2)

        bgContext.perform {
            bgContext.destroy()
        }
        wait(for: [prepareWaitForListUpdate()], timeout: 0.1)
        assertEqual(manager.listItems.count, 0)
    }

    // MARK: -

    func prepareWaitForListUpdate() -> XCTestExpectation {
        let exp = expectation(description: "list update")
        waitListUpdateExp = exp
        return exp
    }

    func prepareWaitForHasArchivedChanged() -> XCTestExpectation {
        let exp = expectation(description: "hasArchived change")
        waitArchivedUpdateExp = exp
        return exp
    }

    func prepareWaitForHasDeletedChanged() -> XCTestExpectation {
        let exp = expectation(description: "hasDeleted change")
        waitDeletedUpdateExp = exp
        return exp
    }

    var waitListUpdateExp: XCTestExpectation?
    var waitArchivedUpdateExp: XCTestExpectation?
    var waitDeletedUpdateExp: XCTestExpectation?

    func conversations(_ manager: ConversationManager, listUpdated: [Conversation]) {
        print("Test> Receive list update.")
        waitListUpdateExp?.fulfill()
        waitListUpdateExp = nil
    }

    func conversations(_ manager: ConversationManager, hasArchived: Bool) {
        waitArchivedUpdateExp?.fulfill()
        waitArchivedUpdateExp = nil
    }

    func conversations(_ manager: ConversationManager, hasDeleted: Bool) {
        waitDeletedUpdateExp?.fulfill()
        waitDeletedUpdateExp = nil
    }
}
