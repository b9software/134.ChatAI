//
//  OAChatResponse.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name nesting

enum OAChatRole: RawRepresentable, Codable {
    case assistant
    case system
    case user
    case unknown(String)

    init(rawValue: String) {
        switch rawValue {
        case "assistant": self = .assistant
        case "system": self = .system
        case "user": self = .user
        default: self = .unknown(rawValue)
        }
    }

    var rawValue: String {
        switch self {
        case .assistant: return "assistant"
        case .system: return "system"
        case .user: return "user"
        case .unknown(let string): return string
        }
    }
}


struct OAChatCompletion: Codable {
//    private(set) var id: String?
    private(set) var object: String?
//    private(set) var created: Timestamp?
//    private(set) var model: String?
//    private(set) var usage: Usage?
    private(set) var choices: [Choice]?

//    struct Usage: Codable {
//        private(set) var prompt_tokens: Int?
//        private(set) var completion_tokens: Int?
//        private(set) var total_tokens: Int?
//    }

    struct Choice: Codable {
        private(set) var message: Message?
        private(set) var finish_reason: String?
        private(set) var index: Int?

        struct Message: Codable {
            private(set) var role: OAChatRole
            private(set) var content: String
        }
    }
}
