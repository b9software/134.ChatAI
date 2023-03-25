//
//  ApplicationCondition.swift
//  App
//

#if canImport(B9Condition)
import B9Condition

// swiftlint:disable:next identifier_name
func AppCondition() -> Condition<Set<ApplicationCondition>> {
    globalCondition
}
private let globalCondition = Condition<Set<ApplicationCondition>>()

/**
关于状态

ApplicationCondition 描述的应该是可以持续的状态，而不是一个瞬间发生的事件，
事件用通知、delegate 之类的响应就好了，Condition 不是干这个的。

@warning ApplicationCondition 状态不应持久化
*/
enum ApplicationCondition {
    // - 应用整体状态
    case databaseReady

    /// 网络是否在线
    case online

    /// 使用 Wi-Fi 联网
    case wifi
}

/// 窗口内部的状态
enum SceneCondition {

}

#endif
