/*
 对特殊约定的数据类型进行定义以示区分
 */

// swiftlint:disable type_name

/// 标识符
typealias StringID = String

/// 时间戳，相对于 1970，非毫秒
typealias Timestamp = Int

typealias L = L10n.Localizable

protocol ModelValidate {
    func validate() throws
}
