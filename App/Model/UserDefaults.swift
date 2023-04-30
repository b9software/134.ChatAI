//
//  UserDefaults 字段定义
//  App
//

import Foundation

/**
 使用建议：

 UserDefaults 存一些简单的数据还是很好用的，方便，性能可以。但毕竟不是真正的数据库，应避免存入大量的数据。

 我记得它有存储量的限制，但文档里找不到了。在过去的实践中，存入量大时会出现存不进去的现象。
 */
extension UserDefaults {
    /// 上次启动时间
    var applicationLastLaunchTime: Date? {
        get { object(forKey: #function) as? Date }
        set { set(newValue, forKey: #function) }
    }

    /// 上次启动时版本
    var lastVersion: String? {
        get { string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    /// 上次更新版本时的版本
    var previousVersion: String? {
        get { string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    /// App 总启动次数
    var launchCount: Int {
        get { integer(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    /// 当前版本启动次数
    var launchCountCurrentVersion: Int {
        get { integer(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    // MARK: -

    var iCloudEnable: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    /// 颜色主题，0 system, 1 light, 2 dark
    var preferredTheme: Int {
        get { integer(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    var preferredContentSize: UIContentSizeCategory {
        get {
            guard let raw = string(forKey: #function) else {
                return .unspecified
            }
            return UIContentSizeCategory(rawValue: raw)
        }
        set { set(newValue.rawValue, forKey: #function) }
    }

    /// 双击选中文本后自动复制文本到剪贴板
    var chatSendClipboardWhenLabelEdit: Bool {
        get { value(forKey: #function) as? Bool ?? true }
        set { set(newValue, forKey: #function) }
    }

    var floatWindowAlpha: Float {
        get { value(forKey: #function) as? Float ?? 0.2 }
        set { set(newValue, forKey: #function) }
    }

    var preferredSendbyKey: Sendby {
        get {
            let value = integer(forKey: #function)
            return Sendby(rawValue: value) ?? .command
        }
        set { set(newValue.rawValue, forKey: #function) }
    }

    /// 最近用户选择的引擎 ID
    var lastEngine: StringID? {
        get { string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}

// MARK: - 存储类型支持

extension UserDefaults {
    // JSON Model 存储支持
    private func model<T: MBModel>(forKey key: String) -> T? {
        guard let data = data(forKey: key),
              let model = try? T(data: data) else {
            return nil
        }
        return model
    }
    private func set(model value: MBModel?, forKey key: String) {
        let data = value?.toJSONData()
        set(data, forKey: key)
    }

    // Codable 对象存储支持
    private func model<T: Codable>(forKey key: String) -> T? {
        guard let data = data(forKey: key),
              let model = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return model
    }
    private func set<T: Codable>(model value: T?, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: key)
    }
}
