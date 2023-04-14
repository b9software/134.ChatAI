//
//  Current.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum Current {
    static let bundleID = "b9software.chat-ai"

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

    static var identifierForVendor: String {
        Mocked.identifierForVendor ?? {
            let uuid = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
            Mocked.identifierForVendor = uuid
            return uuid
        }()
    }

    static var messageSender: MessageSender {
        Mocked.messageSender ?? {
            let instance = MessageSender()
            Mocked.messageSender = instance
            return instance
        }()
    }

    static var osBridge: MacInterface {
        Mocked.osBridge ?? {
            #if targetEnvironment(macCatalyst)
            let instance = MockedMacInterface.load() ?? MockedMacInterface()
            #else
            let instance = MockedMacInterface()
            #endif
            Mocked.osBridge = instance
            return instance
        }()
    }

    static var userAgent: String {
        Mocked.userAgent ?? {
            let exeName = Bundle.main.executableURL?.lastPathComponent ?? "B9ChatAI"
            let version = MBApp.global.version
            let sysVer = UIDevice.current.systemVersion
            #if targetEnvironment(macCatalyst)
            let device = "macOS; catalyst/\(sysVer)"
            #else
            let device = "\(UIDevice.current.model); iOS/\(sysVer)"
            #endif
            let result = "\(exeName)/\(version) (\(device))"
            Mocked.userAgent = result
            return result
        }()
    }
}

enum Mocked {
    static var conversationManager: ConversationManager?
    static var database: DBManager?
    static var identifierForVendor: String?
    static var messageSender: MessageSender?
    static var osBridge: MacInterface?
    static var userAgent: String?

    static func reset() {
        conversationManager = nil
        database = nil
        identifierForVendor = nil
        messageSender = nil
        osBridge = nil
        userAgent = nil
    }
}
