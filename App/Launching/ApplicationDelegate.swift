//
//  ApplicationDelegate.swift
//  App
//

import B9Condition
import Debugger
import UIKit

/**
 注意是基于 MBApplicationDelegate 的，大部分 UIApplicationDelegate 方法需要调用 super

 外部推荐尽可能通过 addAppEventListener() 来监听事件；
 MBApplicationDelegate 默认未分发的方法可以自定义，通过 enumerateEventListeners() 方法进行分发。
 */
@main
class ApplicationDelegate: MBApplicationDelegate {
    let debug = DebugManager()

    override func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }

    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if UIApplication.shared.connectedScenes.isEmpty {
//                exit(0)
//            }
//        }
    }

    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AppUserDefaultsShared().applicationLastLaunchTime = Date()
        _ = MBApp.status()
        return true
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if PREVIEW
        #elseif DEBUG
        // https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
        #endif
//        MBEnvironment.registerWorkers()
        RFKeyboard.autoDisimssKeyboardWhenTouch = true
        setupUIAppearance()
        dispatch_after_seconds(0, setupDebugger)
        return true
    }

    private func setupDebugger() {
        Debugger.globalActionItems = [
            DebugActionItem("FLEX") {
                MBFlexInterface.showFlexExplorer()
            }
        ]
//        Debugger.vauleInspector = { value in
//            if let vc = MBFlexInterface.explorerViewController(for: value) {
//                AppNavigationController()?.pushViewController(vc, animated: true)
//            }
//        }
    }

    private func setupUIAppearance() {
        // 统一全局色，storyboard 的全局色只对部分 UI 生效，比如无法对 UIAlertController 应用
        window.tintColor = UIColor(named: "primary")!

        #if DEBUG
        // 强制修改窗口的最小尺寸，用以调试小屏幕适配
        window.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 200, height: 300)
        #endif

        // 列表 data source 全局调整
        MBListDataSource<AnyObject>.defualtPageStartZero = false
        MBListDataSource<AnyObject>.defaultPageSizeParameterName = "size"
        MBListDataSource<AnyObject>.defaultFetchFailureHandler = { _, error in
            let e = error as NSError
            if e.domain == NSURLErrorDomain &&
                (e.code == NSURLErrorTimedOut
                || e.code == NSURLErrorNotConnectedToInternet) {
                // 超时断网不报错
            } else {
                AppHUD().alertError(e, title: nil, fallbackMessage: "列表加载失败")
            }
            return false
        }
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        if !AppCondition().meets([.appHasEnterForegroundOnce]) {
            AppCondition().set(on: [.appHasEnterForegroundOnce])
            AppUserDefaultsShared().launchCount += 1
            AppUserDefaultsShared().launchCountCurrentVersion += 1
        }
        AppCondition().set(on: [.appInForeground])
        super.applicationDidBecomeActive(application)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        AppCondition().set(off: [.appInForeground])
        debugPrint(#function)
        super.applicationDidEnterBackground(application)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        var hasHande = false
        enumerateEventListeners { listener in
            if listener.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? false {
                hasHande = true
            }
        }
        return hasHande
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return super.application(app, open: url, options: options)
    }
}

// MARK: - Responder Chain
extension ApplicationDelegate {
    override func validate(_ command: UICommand) {
        super.validate(command)
        debugPrint(command)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let result = super.canPerformAction(action, withSender: sender)
        if debug.debugResponder {
            AppLog().debug("Responder> Can perform \(action) = \(result)")
        }
        return result
    }

    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        let target = super.target(forAction: action, withSender: sender)
        if debug.debugResponder {
            AppLog().debug("Responder> action: \(action), sender: \(sender.debugDescription), target: \(target.debugDescription)")
        }
        return target
    }
}

// MARK: - Menu
extension ApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        if builder.system == .main {
            ApplicationMenu.build(builder)
        }
    }

    @IBAction func showHelp(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/b9software")!)
    }
}
