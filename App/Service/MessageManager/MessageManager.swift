/**
 MessageManager.swift
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 
 */
@objc
class MessageManager: NSObject {

    /**
     显示加载状态
     */
    @objc func showActivityIndicator(withIdentifier identifier: String, groupIdentifier group: String?, model: Bool, message: String?) {
        assertionFailure()
    }

    /**
     显示一个操作成功的信息，显示一段时间后自动隐藏
     */
    @objc func showSuccessStatus(_ message: String?) {
        assertionFailure()
    }

    /**
     队列显示一段文本，显示一段时间后自动隐藏
     */
    @objc func showInfoStatus(_ message: String?) {
        assertionFailure()
    }

    /**
     显示一个错误提醒，一段时间后自动隐藏
     */
    @objc func showErrorStatus(_ message: String?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        Current.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}
