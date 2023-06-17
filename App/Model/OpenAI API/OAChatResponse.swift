//
//  OAChatResponse.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum OAChatRole: RawRepresentable, Codable, Equatable {
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

    var isUnknown: Bool {
        if case .unknown = self {
            return true
        }
        return false
    }
}

/// 发送与接收都使用
struct OAChatMessage: Codable, Equatable {
    private(set) var role: OAChatRole?
    private(set) var content: String?
}

/// 非流式返回
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
        private(set) var index: Int?
        private(set) var message: OAChatMessage?
        private(set) var delta: OAChatMessage?
        private(set) var finishReason: String?
    }
}

// MARK: - Error

struct OAErrorDetail: Codable {
    var message: String?
    var type: String?
    var code: String?
}

struct OAError: Codable, LocalizedError {
    var error: OAErrorDetail?

    var errorDescription: String? {
        guard let info = error else {
            return "Unknown OpenAI error."
        }
        var msg = info.message ?? "Unknown OpenAI error."
        if let type = info.code ?? info.type {
            msg += " [\(type)]"
        }
        return msg
    }

    var isInvalidApiKey: Bool {
        error?.code == "invalid_api_key"
    }

    static func badString() -> OAError {
        OAError(error: OAErrorDetail(message: "Unknow error with bad content.", type: "bad_content"))
    }

    static func badContext(_ str: String) -> OAError {
        let context = str.trimming(toLength: 100)
        return OAError(error: OAErrorDetail(message: "Bad content: \(context)", type: "bad_content"))
    }
}
