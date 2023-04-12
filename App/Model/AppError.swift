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
        if let err = err as? AppError {
            if case .cancel = err {
                return true
            }
            return false
        }
        if err is CancellationError {
            return true
        }
        if let urlError = err as? URLError {
            return urlError.code == .cancelled
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
