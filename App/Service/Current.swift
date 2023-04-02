//
//  Current.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/1.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum Current {
    static var conversationManager: ConversationManager {
        Mocked.conversationManager ?? {
            let instance = ConversationManager()
            Mocked.conversationManager = instance
            return instance
        }()
    }

    static var database: DBManager {
        Mocked.database ?? {
            let instance = DBManager.setup(test: AppDelegate().isTesting)
            Mocked.database = instance
            return instance
        }()
    }

    static var osBridge: MacInterface {
        Mocked.osBridge ?? {
            let instance = MockedMacInterface.load() ?? MockedMacInterface()
            Mocked.osBridge = instance
            return instance
        }()
    }
}

enum Mocked {
    static var conversationManager: ConversationManager?
    static var database: DBManager?
    static var osBridge: MacInterface?

    static func reset() {
        conversationManager = nil
        database = nil
        osBridge = nil
    }
}
