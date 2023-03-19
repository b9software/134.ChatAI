/**
 MessageManager.swift
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 
 */
class MessageManager: RFSVProgressMessageManager {

    /**
     显示加载状态
     */
    @objc func showActivityIndicator(withIdentifier identifier: String, groupIdentifier group: String?, model: Bool, message: String?) {
        let msg = RFNetworkActivityMessage(identifier: identifier, message: message, status: .loading)
        msg.groupIdentifier = group ?? ""
        msg.modal = model
        show(msg)
    }

    /**
     显示一个操作成功的信息，显示一段时间后自动隐藏
     */
    @objc func showSuccessStatus(_ message: String?) {
        let msg = RFNetworkActivityMessage(identifier: "", message: message, status: .success)
        msg.priority = .high
        show(msg)
    }

    /**
     队列显示一段文本，显示一段时间后自动隐藏
     */
    @objc func showInfoStatus(_ message: String?) {
        let msg = RFNetworkActivityMessage(identifier: "", message: message, status: .info)
        msg.priority = .high
        show(msg)
    }

    /**
     显示一个错误提醒，一段时间后自动隐藏
     */
    @objc func showErrorStatus(_ message: String?) {
        let msg = RFNetworkActivityMessage(identifier: "", message: message, status: .fail)
        msg.priority = .high
        show(msg)
    }
}
