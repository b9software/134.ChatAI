//
//  AppError.swift
//  App
//

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
