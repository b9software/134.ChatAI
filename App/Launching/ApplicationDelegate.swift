//
//  ApplicationDelegate.swift
//  App
//

import AppFramework
import B9Action
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
//        if isTesting {
//            return UISceneConfiguration()
//        }
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
        #if DEBUG
        MBAssertSetHandler { message, file, line in
            assertionFailure(message, file: file, line: line)
        }
        #endif
        Current.defualts.applicationLastLaunchTime = Date()
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
            debugUpdateFlags()
#endif
        }
        setupUIAppearance()
        if isTesting { return true }
        Current.messageSender.startIfNeeded()
        #if targetEnvironment(macCatalyst)
        dispatch_after_seconds(0, setupFloatModeObservation)
        #endif
        return true
    }

    private func setupDebugger() {
        Debugger.globalActionItems = [
        ]
    }

    private func setupUIAppearance() {
    }

    override func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        AppLog().info("App> UserActivity did update: \(userActivity).")
    }

    #if targetEnvironment(macCatalyst)
    private lazy var needsUpdateFloatModeState = DelayAction(.init(updateFloatModeState))
    #endif
}

// MARK: - Float Window
#if targetEnvironment(macCatalyst)
extension ApplicationDelegate {
    private func setupFloatModeObservation() {
        Current.osBridge.keyWindowChangeObserver = {
            if let state = FloatModeState(rawValue: Current.osBridge.keyWindowFloatMode) {
                ApplicationMenu.keyWindowFloatModeState = state
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onFloatModeChanged(notice:)), name: .floatModeDidChange, object: nil)
    }

    @objc func onFloatModeChanged(notice: Notification) {
        updateFloatModeState()
    }

    private func updateFloatModeState() {
        guard let state = FloatModeState(rawValue: Current.osBridge.keyWindowFloatMode) else {
            return
        }
        keySceneDelegate()?.floatModeState = state
        ApplicationMenu.keyWindowFloatModeState = state
        AppLog().debug("App> Key window float state: \(state).")
    }

    @IBAction func enterFloatMode(_ sender: Any) {
        AppLog().debug("Enter float mode: \(keyScene()?.title)")
        keySceneDelegate()?.floatModeState = .floatExpand
        Current.osBridge.keyWindowFloatMode = FloatModeState.floatExpand.rawValue
    }

    @IBAction func exitFloatMode(_ sender: Any) {
        AppLog().debug("Exit float mode: \(keyScene()?.title)")
        Current.osBridge.keyWindowFloatMode = FloatModeState.normal.rawValue
    }

    @IBAction func floatWindowExpand(_ sender: Any) {
        assert(Current.osBridge.keyWindowFloatMode > 1)
        keySceneDelegate()?.floatModeState = .floatExpand
        Current.osBridge.keyWindowFloatMode = FloatModeState.floatExpand.rawValue
    }

    @IBAction func floatWindowCollapse(_ sender: Any) {
        assert(Current.osBridge.keyWindowFloatMode > 1)
        // @bug: 多个 window，点击非激活窗口的按钮触发时，UIKit 的 key window 没有及时更新，导致窗口和窗口内容状态不一致
        keySceneDelegate()?.floatModeState = .floatCollapse
        Current.osBridge.keyWindowFloatMode = FloatModeState.floatCollapse.rawValue
    }

    private func keyScene() -> UIWindowScene? {
        Current.keyWindow?.windowScene
    }

    private func keySceneDelegate() -> SceneDelegate? {
        Current.keyWindow?.windowScene?.delegate as? SceneDelegate
    }
}
#endif

// MARK: - Responder Chain
#if DEBUG
private var lastCanPerformAction: Selector?
private var lastTargetAction: Selector?

extension ApplicationDelegate {
    override func validate(_ command: UICommand) {
        super.validate(command)
        if debug.debugSystemUI {
            debugPrint(command)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let result = super.canPerformAction(action, withSender: sender)
        if lastCanPerformAction != action {
            lastCanPerformAction = action
            Current.responderLog.debug("Responder> Can perform \(action) = \(result)")
        }
        return result
    }

    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        let target = super.target(forAction: action, withSender: sender)
        if lastTargetAction != action {
            lastTargetAction = action
            Current.responderLog.debug("Responder> action: \(action), sender: \(sender.debugDescription), target: \(target.debugDescription)")
        }
        return target
    }
}
#endif // End debug

// MARK: - Menu
extension ApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        if builder.system == .main {
            ApplicationMenu.build(builder)
        }
    }

    @IBAction func showHelp(_ sender: Any) {
        URL.open(link: L.Link.homePage)
    }

    @IBAction func showUserManual(_ sender: Any) {
        URL.open(link: L.Link.userManual)
    }

    @IBAction func showFeedback(_ sender: Any) {
        URL.open(link: L.Link.feedback)
    }
}
