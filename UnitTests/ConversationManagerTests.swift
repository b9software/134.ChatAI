//
//  ConversationManagerTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import CoreData
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

        assertEqual(manager.hasArchived, false)
        assertEqual(manager.hasDeleted, false)

        let archived1 = ctx.createConversation()
        let deleted1 = ctx.createConversation()
        exceptDeletedChanged {
            ctx.perform {
                XCTAssertFalse(archived1.isDeleted)
                XCTAssertFalse(deleted1.isDeleted)
                archived1.archiveTime = .current
                deleted1.deleteTime = .current
                ctx.trySave()
            }
        }
        assertEqual(manager.hasArchived, true)
        assertEqual(manager.hasDeleted, true)

        exceptArchivedChanged {
            ctx.perform {
                ctx.delete(archived1)
                ctx.trySave()
            }
        }
        assertEqual(manager.hasArchived, false)

        exceptArchivedChanged {
            ctx.perform {
                let archived2 = ctx.createConversation()
                archived2.archiveTime = .current
                ctx.trySave()
            }
        }
        assertEqual(manager.hasArchived, true)

        exceptDeletedChanged {
            ctx.perform {
                ctx.delete(deleted1)
                ctx.trySave()
            }
        }
        assertEqual(manager.hasDeleted, false)

        exceptDeletedChanged {
            ctx.perform {
                let deleted2 = ctx.createConversation()
                deleted2.deleteTime = .current
                ctx.trySave()
            }
        }
        assertEqual(manager.hasDeleted, true)
    }

    func testListTrack() {
        let manager = ConversationManager()
        manager.delegates.add(self)
        let ctx = manager.context
        ctx.assertIsFresh()
        defer { ctx.destroy() }
        exceptListUpdate {
            // init
        }

        let entity1 = exceptListUpdate {
            ctx.createConversation()
        }
        assertEqual(manager.listItems.count, 1)

        let entity2 = exceptListUpdate {
            return ctx.createConversation()
        }
        assertEqual(manager.listItems.count, 2)

        exceptListUpdate {
            ctx.performAndWait {
                ctx.delete(entity1)
                ctx.delete(entity2)
                ctx.trySave()
            }
        }
        assertEqual(manager.listItems.count, 0)
    }

    func testListTrackInOtherContext() {
        let manager = ConversationManager()
        manager.delegates.add(self)
        let ctx = manager.context
        ctx.assertIsFresh()
        defer { ctx.destroy() }
        exceptListUpdate {
            // init
        }

        let bgContext = Current.database.container.newBackgroundContext()
        exceptListUpdate {
            bgContext.perform {
                _ = bgContext.createConversation()
            }
        }
        assertEqual(manager.listItems.count, 1)

        exceptListUpdate {
            bgContext.perform {
                _ = bgContext.createConversation()
            }
        }
        assertEqual(manager.listItems.count, 2)

        exceptListUpdate {
            bgContext.performAndWait {
                bgContext.destroy()
            }
        }
        assertEqual(manager.listItems.count, 0)
    }

    // MARK: -

    func exceptListUpdate<T>(_ operation: () -> T) -> T {
        let exp = expectation(description: "list update")
        waitListUpdateExp = exp
        let result = operation()
        wait(for: [exp], timeout: 0.1)
        return result
    }

    func exceptArchivedChanged(_ operation: () -> Void) {
        let exp = expectation(description: "hasArchived change")
        waitArchivedUpdateExp = exp
        operation()
        wait(for: [exp], timeout: 0.1)
    }

    func exceptDeletedChanged(_ operation: () -> Void) {
        let exp = expectation(description: "hasDeleted change")
        waitDeletedUpdateExp = exp
        operation()
        wait(for: [exp], timeout: 0.1)
    }

    var waitListUpdateExp: XCTestExpectation?
    var waitArchivedUpdateExp: XCTestExpectation?
    var waitDeletedUpdateExp: XCTestExpectation?

    func conversations(_ manager: ConversationManager, listUpdated: [Conversation]) {
        print("Test> Receive list update.")
        dispatch_after_seconds(0) { [self] in
            waitListUpdateExp?.fulfill()
            waitListUpdateExp = nil
        }
    }

    func conversations(_ manager: ConversationManager, hasArchived: Bool) {
        dispatch_after_seconds(0) { [self] in
            waitArchivedUpdateExp?.fulfill()
            waitArchivedUpdateExp = nil
        }
    }

    func conversations(_ manager: ConversationManager, hasDeleted: Bool) {
        dispatch_after_seconds(0) { [self] in
            waitDeletedUpdateExp?.fulfill()
            waitDeletedUpdateExp = nil
        }
    }
}
