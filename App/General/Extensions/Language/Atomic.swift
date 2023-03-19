/*
 Atomic.swift
 
 Copyright © 2019 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

// @MBDependency:2
/**
 多线程自动安全访问变量
 
 https://www.objc.io/blog/2018/12/18/atomic-variables/
 */
final class Atomic<A> {
    private lazy var queue = DispatchQueue(label: "Atomic value")
    private var _value: A
    init(_ value: A) {
        self._value = value
    }

    var value: A {
        queue.sync { self._value }
    }

    func mutate(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
}
