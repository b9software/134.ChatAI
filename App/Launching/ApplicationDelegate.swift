//
//  ApplicationDelegate.swift
//  App
//

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
//        MBEnvironment.registerWorkers()
//        RFKeyboard.autoDisimssKeyboardWhenTouch = true
        setupUIAppearance()
        if isTesting { return true }
        Current.messageSender.startIfNeeded()
        dispatch_after_seconds(0, setupFloatModeObservation)
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
    }

    override func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        AppLog().info("App> UserActivity did update: \(userActivity).")
    }

    private var keyWindowFloatModeState = FloatModeState.normal
    private lazy var needsUpdateFloatModeState = DelayAction(.init(updateFloatModeState))
}

// MARK: - Float Window
enum FloatModeState: Equatable {
    case normal
    case floatExpand
    case floatCollapse
}

extension ApplicationDelegate {


    private func setupFloatModeObservation() {
        Current.osBridge.keyWindowChangeObserver = {
            self.needsUpdateFloatModeState.set()
        }
    }

    private func updateFloatModeState() {
        var state: FloatModeState = .normal
        if Current.osBridge.keyWindowIsInFloatMode {
            state = Current.osBridge.keyWindowIsFloatExpand ? .floatExpand : .floatCollapse
        }
        if keyWindowFloatModeState == state { return }
        keyWindowFloatModeState = state
        AppLog().debug("App> Key window float state: \(state).")
        ApplicationMenu.setNeedsRebuild()
    }

    func buildFloatModeMenu() -> UIMenu {
        let children: [UIKeyCommand]
        switch keyWindowFloatModeState {
        case .normal:
            children = [
                UIKeyCommand(title: L.Menu.floatMode, action: #selector(ApplicationDelegate.enterFloatMode(_:)), input: "Y", modifierFlags: [.command]),
            ]
        case .floatExpand:
            children = [
//                UIKeyCommand(title: L.Menu.floatModeCollapse, action: #selector(ApplicationDelegate.floatWindowCollapse(_:)), input: "Y", modifierFlags: [.command]),
                UIKeyCommand(title: L.Menu.floatModeExit, action: #selector(ApplicationDelegate.exitFloatMode(_:)), input: "Y", modifierFlags: [.command, .shift]),
            ]
        case .floatCollapse:
            children = [
//                UIKeyCommand(title: L.Menu.floatModeExpand, action: #selector(ApplicationDelegate.floatWindowExpand(_:)), input: "Y", modifierFlags: [.command]),
                UIKeyCommand(title: L.Menu.floatModeExit, action: #selector(ApplicationDelegate.exitFloatMode(_:)), input: "Y", modifierFlags: [.command, .shift]),
            ]
        }
        return UIMenu(options: .displayInline, children: children)
    }

    @IBAction func enterFloatMode(_ sender: Any) {
        Current.osBridge.floatWindow()
        debugPrint("Float", keyScene()?.title)
        needsUpdateFloatModeState.set()
    }

    @IBAction func exitFloatMode(_ sender: Any) {
        Current.osBridge.unfloatWindow()
        debugPrint("Un Float", keyScene()?.title)
        needsUpdateFloatModeState.set()
    }

    @IBAction func floatWindowExpand(_ sender: Any) {
        assert(Current.osBridge.keyWindowIsInFloatMode)
        Current.osBridge.keyWindowIsFloatExpand = true
        needsUpdateFloatModeState.set()
    }

    @IBAction func floatWindowCollapse(_ sender: Any) {
        assert(Current.osBridge.keyWindowIsInFloatMode)
        Current.osBridge.keyWindowIsFloatExpand = false
        needsUpdateFloatModeState.set()
    }

    private func keyScene() -> UIWindowScene? {
        Current.keyWindow?.windowScene
    }

    private func keySceneDelegate() -> SceneDelegate? {
        Current.keyWindow?.windowScene?.delegate as? SceneDelegate
    }
}

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
        URL.open(link: L.App.homePage)
    }

    @IBAction func showUserManual(_ sender: Any) {
        URL.open(link: L.App.userManual)
    }
}
