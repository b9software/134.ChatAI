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
