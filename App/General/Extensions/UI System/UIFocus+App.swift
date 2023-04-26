/*
 应用级别的便捷方法: View Controller 扩展
 */

import UIKit

extension UIFocusItem {
    func isChildren(of parent: UIFocusEnvironment) -> Bool {
        var current = parentFocusEnvironment
        while current != nil {
            if current === parent {
                return true
            }
            current = current?.parentFocusEnvironment
        }
        return false
    }
}
