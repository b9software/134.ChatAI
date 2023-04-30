//
//  Notification+App.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

extension Notification.Name {

    func observe(object: Any? = nil, queue: OperationQueue? = nil, callback: @escaping (Notification) -> Void) -> NotificationObserver {
        let nsObject = NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: callback)
        return NotificationObserver(object: nsObject)
    }
}

class NotificationObserver {
    private let listener: NSObjectProtocol

    fileprivate init(object: NSObjectProtocol) {
        listener = object
    }

    deinit {
        NotificationCenter.default.removeObserver(listener)
    }
}
