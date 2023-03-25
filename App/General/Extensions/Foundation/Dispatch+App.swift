/*
 应用级别的便捷方法：GCD 相关扩展
 */

import Foundation

/**
 Wrapper of `dispatchPrecondition()` function, it only takes effect in debug builds.

 Since the dispatchPrecondition function stops program execution with the default release setting.
 */
@inline(__always)
func assertDispatch(_ condition: @autoclosure () -> DispatchPredicate) {
    #if DEBUG
    dispatchPrecondition(condition: condition())
    #endif
}

/**
 `DispatchQueue.main.sync` without deadlock on main thread
 */
func dispatchSyncOnMain<T>(_ block: () throws -> T) rethrows -> T {
    if Thread.isMainThread {
        return try block()
    } else {
        return try DispatchQueue.main.sync(execute: block)
    }
}
