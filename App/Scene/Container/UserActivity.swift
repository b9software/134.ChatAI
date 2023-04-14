//
//  UserActivity.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

enum UserActivityType: String {
    case newConversation = "b9software.chat-ai.activity.newConversation"
    case conversation = "b9software.chat-ai.activity.conversation"
    case setting = "b9software.chat-ai.activity.setting"
    case guide = "b9software.chat-ai.activity.guide"
}

extension NSUserActivity {
    convenience init(_ type: UserActivityType) {
        self.init(activityType: type.rawValue)
    }

    convenience init(conversationID: StringID) {
        self.init(activityType: UserActivityType.conversation.rawValue)
        addUserInfoEntries(from: ["id": conversationID])
    }
}
