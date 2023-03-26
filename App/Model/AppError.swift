//
//  AppError.swift
//  App
//

/// App 用错误
enum AppError: LocalizedError {

    /// 包含一条信息的错误
    case message(_ message: String)

    var errorDescription: String? {
        switch self {
        case let .message(text):
            return text
        }
    }
}

enum ModelError: LocalizedError {
    /// 模型验证失败
    case invalid(String)

    var errorDescription: String? {
        switch self {
        case let .invalid(text):
            return "Invalid model: \(text)"
        }
    }
}
