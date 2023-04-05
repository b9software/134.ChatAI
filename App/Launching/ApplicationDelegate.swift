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

    #if DEBUG
    lazy var isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    #else
    let isTesting = false
    #endif

    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if isTesting {
            return UISceneConfiguration()
        }
        return UISceneConfiguration(name: "Main", sessionRole: .windowApplication)
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
        _ = Current.database
        return true
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        if !isTesting {
#if DEBUG
            // https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster
            Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
            dispatch_after_seconds(0, setupDebugger)
#endif
        }
//        MBEnvironment.registerWorkers()
//        RFKeyboard.autoDisimssKeyboardWhenTouch = true
        setupUIAppearance()
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

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AppLog().info("App> Open \(url). \(options)")
        return super.application(app, open: url, options: options)
    }

    override func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        AppLog().info("App> UserActivity will continue: \(userActivityType).")
        if isTesting { return false }
        return true
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppLog().info("App> UserActivity continue: \(userActivity).")
        var hasHande = false
        enumerateEventListeners { listener in
            if listener.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? false {
                hasHande = true
            }
        }
        return hasHande
    }

    override func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        AppLog().info("App> UserActivity did update: \(userActivity).")
    }

    override func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        AppLog().error("App> UserActivity fail to continue: \(userActivityType) \(error).")
    }

    override func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        AppLog().error("App> Perform Action: \(shortcutItem).")
        completionHandler(false)
        // 似乎可以只启动不激活
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
            if !["toolbarBack:"].contains(action.description) {
                AppLog().debug("Responder> Can perform \(action) = \(result)")
            }
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
