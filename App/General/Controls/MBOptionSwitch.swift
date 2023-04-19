/*
 MBOptionSwitch

 Copyright © 2018, 2022 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import UIKit

// @MBDependency:2
/**
 自动从 NSUserDefaults 读取设置并可自动更新首选项的 UISwitch
 */
final class MBOptionSwitch: UISwitch {
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
            updateOn()
        }
    }

    func updateOn() {
        guard let optionKey = optionKey else {
            return
        }
        let defaults = Current.defualts
        var value = defaults.value(forKey: optionKey)
        if value != nil, !(value is NSNumber) {
            AppLog().error("Except \(optionKey) to be a NSNumber, got \(value as Any).")
            value = nil
        }
        let valueInConfig = (value as? NSNumber)?.boolValue ?? false
        isOn = reversed ? !valueInConfig : valueInConfig
    }

    @objc private func onValueChanged() {
        let defaults = Current.defualts
        if let key = optionKey {
            defaults.setValue((reversed ? !isOn : isOn), forKey: key)
            defaults.synchronize()
        }
    }
}
