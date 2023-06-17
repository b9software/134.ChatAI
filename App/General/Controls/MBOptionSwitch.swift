/*
 MBOptionSwitch

 Copyright © 2018, 2022-2023 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import B9AssociatedObject
import UIKit

protocol OptionControl: AnyObject {
    associatedtype ValueType

    var optionKey: String? { get }

    /// 当前 UI 状态代表的 UserDefaults 值
    var defaultValue: ValueType { get }

    /// 获取 UserDefaults 中新的值并刷新 UI
    func updateValue()
}

private let notificationListener = AssociatedObject<NotificationObserver>()
extension OptionControl {
    var isDefaultChangeNotificationEnable: Bool {
        get {
            if let observer = notificationListener[self] {
                return observer !== NSNull()
            }
            return false
        }
        set {
            if isDefaultChangeNotificationEnable == newValue { return }
            if newValue {
                notificationListener[self] = UserDefaults.didChangeNotification.observe(queue: .main, callback: { [weak self] _ in
                    self?.updateValue()
                })
            } else {
                notificationListener[self] = nil
            }
        }
    }

    func loadDefaultValue() -> ValueType? {
        let defaults = Current.defualts
        guard let key = optionKey else { return nil }
        return defaults.value(forKey: key) as? ValueType
    }

    func saveDefaultValue() {
        let defaults = Current.defualts
        guard let key = optionKey else { return }
        defaults.setValue(defaultValue, forKey: key)
        defaults.synchronize()
    }
}

// @MBDependency:2
/**
 自动从 NSUserDefaults 读取设置并可自动更新首选项的 UISwitch
 */
final class MBOptionSwitch: UISwitch, OptionControl {
    /// 设定为 key 值，不是属性名
    @IBInspectable var optionKey: String?

    /// 显示与存储值是相反的
    @IBInspectable var reversed: Bool = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    private func onInit() {
        addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            updateValue()
            isDefaultChangeNotificationEnable = true
        } else {
            isDefaultChangeNotificationEnable = false
        }
    }

    var defaultValue: Bool {
        reversed ? !isOn : isOn
    }

    func updateValue() {
        let valueInConfig = loadDefaultValue() ?? false
        isOn = reversed ? !valueInConfig : valueInConfig
    }

    @objc private func onValueChanged() {
        saveDefaultValue()
    }
}

final class MBOptionSlider: UISlider, OptionControl {
    /// 设定为 key 值，不是属性名
    @IBInspectable var optionKey: String?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    private func onInit() {
        addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            updateValue()
            isDefaultChangeNotificationEnable = true
        } else {
            isDefaultChangeNotificationEnable = false
        }
    }

    var defaultValue: Float { value }

    func updateValue() {
        value = Current.defualts.floatWindowAlpha
    }

    @objc private func onValueChanged() {
        saveDefaultValue()
    }
}
