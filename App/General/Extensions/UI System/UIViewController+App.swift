/*
 应用级别的便捷方法: View Controller 扩展
 */
extension UIViewController {

    /// 用系统弹窗提示一段信息
    func alert(title: String?, message: String?, buttonTitle: String = "知道了") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        rfPresent(alert, animated: true, completion: nil)
    }

    /// 用系统弹窗提示权限方面的问题，用户可选择跳转到应用设置
    func permissionPrompt(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
            UIApplication.openSettings()
        }))
        rfPresent(alert, animated: true, completion: nil)
    }
}


extension UIViewController {
    // @MBDependency:4
    /**
     安全的 presentViewController，仅当当前 vc 是导航中可见的 vc 时才 present

     - Parameters:
        - viewControllerToPresent: 需要展示的 vc
        - flag: 是否需要动画
        - completion: presented 参数代表给定 vc 是否被弹出
     */
    func rfPresent(_ viewControllerToPresent: UIViewController, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let nav = navigationController else {
            assert(false, "当前 vc 不在导航中，RFPresent 只支持处于导航中的 vc 管理")
            completion?(false)
            return
        }
        guard let navVisible = nav.visibleViewController else {
            completion?(false)
            return
        }
        var isNavVisible = false
        var vc = self
        while let parent = vc.parent {
            if parent == navVisible {
                isNavVisible = true
                break
            }
            vc = parent
        }
        if !isViewLoaded || !isNavVisible {
            completion?(false)
            return
        }
        nav.present(viewControllerToPresent, animated: animated) {
            completion?(true)
        }
    }
}
