//
//  ConversationTests.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import CoreData
import XCTest

// swiftlint:disable force_try

class ConversationTests:
    TestCase,
    ConversationUpdating
{
    override class var mockResetPoint: TestCase.ResetPoint { [.tearDown] }

    func testUsableStateArchived() async {
        let item = await Current.database.read { ctx in
            let entity = CDConversation(context: ctx)
            entity.id = "test" + UUID().uuidString
            entity.archiveTime = .current
            return Conversation.from(entity: entity)
        }
        assertEqual(item.usableState, .normal)

        item.delegates.add(self)
        item.requireUsableState()
        waitUsableStateChanged()
        assertEqual(item.usableState, .archived)
    }

    func testUsableStateNoEngine() async {
        let item = await Current.database.read { ctx in
            let entity = CDConversation(context: ctx)
            entity.id = "test" + UUID().uuidString
            return Conversation.from(entity: entity)
        }
        assertEqual(item.usableState, .normal)

        item.delegates.add(self)
        item.requireUsableState()
        waitUsableStateChanged()
        assertEqual(item.usableState, .forceSetup)
    }

    func testUsableStateEngine() async {
        let testID = "test" + UUID().uuidString
        let keychain = MockedKeychainAccess()
        try! keychain.update(string: "test-key", account: testID)
        Mocked.keychain = keychain

        let item = await Current.database.read { ctx in
            let engine = CDEngine(context: ctx)
            engine.id = testID
            engine.type = Engine.EType.openAI.rawValue
            engine.save(oaEngine: OAEngine(models: [.init(id: "test-model")]))

            let entity = CDConversation(context: ctx)
            entity.id = "test" + UUID().uuidString
            entity.engine = engine
            return Conversation.from(entity: entity)
        }

        item.delegates.add(self)
        assertEqual(item.usableState, .normal)

        // No selected model
        item.requireUsableState()
        waitUsableStateChanged()
        assertEqual(item.engine?.isValid, true)
        assertEqual(item.usableState, .forceSetup)

        // Selecte model
        item.engineConfig = EngineConfig(model: "test-model")
        item.requireUsableState()
        waitUsableStateChanged()
        assertEqual(item.usableState, .normal)

        // Make engine invaild
        item.engine?.oaEngine.apiKey = nil
        assertEqual(item.engine?.isValid, false)
        item.requireUsableState()
        waitUsableStateChanged()
        assertEqual(item.usableState, .engineOutdate)
    }

    // MARK: -

    func waitUsableStateChanged() {
        let exp = expectation(description: "UsableState changed")
        assert(waitUsableStateExp == nil)
        waitUsableStateExp = exp
        wait(for: [exp], timeout: 1)
    }
    private var waitUsableStateExp: XCTestExpectation?

    func conversation(_ item: Conversation, useState: Conversation.UsableState) {
        guard let exp = waitUsableStateExp else {
            return
        }
        waitUsableStateExp = nil
        exp.fulfill()
    }
}

// swiftlint:enable force_try
