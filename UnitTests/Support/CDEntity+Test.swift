//
//  CDEntity+Test.swift
//  UnitTests
//
//  Created by Joseph Zhao on 2023/4/2.
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
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
