//
//  AppError.swift
//  App
//

/// App 用错误
enum AppError: LocalizedError {

    /// 包含一条信息的错误
    case message(_ message: String)

    /// Operation is cancelled
    case cancel

    var errorDescription: String? {
        switch self {
        case let .message(text):
            return text
        case .cancel:
            return "Operation is cancelled"
        }
    }

    /// Conveniently determine if an object is `AppError.cancel`
    static func isCancel(_ err: Error?) -> Bool {
        guard let err = err as? AppError else {
            return false
        }
        if case .cancel = err {
            return true
        }
        return false
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
