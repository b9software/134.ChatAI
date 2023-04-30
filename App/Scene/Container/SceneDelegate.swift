//
//  SceneDelegate.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/19.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SceneDelegate: B9WindowSceneDelegate {
    static var hasApplicationEnterBackground = false

    var rootViewController: RootViewController!

    #if targetEnvironment(macCatalyst)
    private(set) lazy var toolbarController = NSToolbarController()
    private(set) lazy var touchbarController = TouchbarController()
    #endif

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            toolbarController.windowTitleBar = titlebar
            toolbarController.update(additionalItems: [])
        }
        #endif
        AppLog().debug("Scene> Will connect, \(connectionOptions.userActivities).")
        rootViewController = window?.rootViewController as? RootViewController
        assert(rootViewController != nil)
        if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            AppLog().debug("Scene> Choose activity: \(activity.activityType).")
            scene.userActivity = activity
            if let root = rootViewController {
                root.userActivity = activity
            } else {
                assert(false)
            }
        }
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 200, height: 180)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        AppLog().debug("Scene> Disconnect: \(scene.title ?? "?")")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        AppLog().debug("Scene> Active: \(scene.title ?? "?"), activity:  \(scene.session.stateRestorationActivity?.activityType ?? "nil").")
        Self.hasApplicationEnterBackground = false
//        if let activity = window?.windowScene?.userActivity {
//            activity.becomeCurrent()
//        }
        rootViewController.hasBecomeActive = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        AppLog().debug("Scene> Resign active: \(scene.title ?? "?")")
//        if let activity = window?.windowScene?.userActivity {
//            activity.resignCurrent()
//        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        AppLog().debug("Scene> WillEnterForeground: \(scene.title ?? "?")")
    }

    override func sceneDidEnterBackground(_ scene: UIScene) {
        super.sceneDidEnterBackground(scene)
        AppLog().debug("Scene> Background: \(scene.title ?? "?")")
        dispatch_after_seconds(0) {
            if !Current.osBridge.isAppActive {
                Self.hasApplicationEnterBackground = true
            }
        }
        rootViewController.hasBecomeActive = false
    }

#if targetEnvironment(macCatalyst)
    private var toolbarStyle: UITitlebarToolbarStyle = .automatic {
        didSet {
            if let titleBar = window?.windowScene?.titlebar {
                if titleBar.toolbarStyle != toolbarStyle {
                    titleBar.toolbarStyle = toolbarStyle
                }
            }
        }
    }

    var floatModeState = FloatModeState.normal {
        didSet {
            AppLog().debug("Scene> \(window?.windowScene?.title ?? "?") Float mode: \(floatModeState)")
            if oldValue == floatModeState { return }
            rootViewController.floatModeState = floatModeState
            toolbarController.floatModeState = floatModeState
            if let size = window?.windowScene?.sizeRestrictions {
                size.minimumSize = floatModeState.isFloat ? .zero : CGSize(width: 200, height: 180)
            }
            switch floatModeState {
            case .normal:
                break
            case .floatExpand:
                window?.rootViewController = rootViewController
            case .floatCollapse:
                let vc = UIViewController()
                vc.view.backgroundColor = nil
                vc.view.isUserInteractionEnabled = false
                window?.rootViewController = vc
            }
        }
    }
#endif
}

// MARK: -

extension SceneDelegate {
#if targetEnvironment(macCatalyst)
    func setPreferedToolbarStyleDueToLayout(style: UITitlebarToolbarStyle) {
        var newStyle = style
        if floatModeState != .normal {
            newStyle = .unifiedCompact
        }
        if toolbarStyle == newStyle { return }
        toolbarStyle = newStyle
    }
#endif
}

// MARK: - Activity

extension SceneDelegate {
    func scene(_ scene: UIScene, willContinueUserActivityWithType type: String) {
        AppLog().debug("Scene> UserActivity will continue: \(type).")
    }

    func scene(_ scene: UIScene, continue activity: NSUserActivity) {
        AppLog().debug("Scene> UserActivity continue: \(activity).")
    }

    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType type: String, error: Error) {
        AppLog().debug("Scene> UserActivity \(type) fail: \(error).")
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        let result = scene.userActivity
        AppLog().debug("Scene> UserActivity request restoration: \(result?.activityType ?? "nil").")
        return result
    }

    func scene(_ scene: UIScene, restoreInteractionStateWith activity: NSUserActivity) {
        AppLog().debug("Scene> UserActivity restore interaction: \(activity).")
    }

    func scene(_ scene: UIScene, didUpdate activity: NSUserActivity) {
        AppLog().debug("Scene> UserActivity did update: \(activity).")
    }
}

// MARK: - URL

extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        AppLog().debug("Scene> Open url \(URLContexts)")
        debugPrint(UIApplication.shared.applicationState.debugDescription)
        for context in URLContexts {
            handleURL(context.url, scene: scene)
        }
//        if Self.hasApplicationEnterBackground {
//            Current.osBridge.hideApp()
//        }
    }

    private func handleURL(_ url: URL, scene: UIScene) {
        func alertUnsupported() {
            let urlContent = url.absoluteString.trimming(toLength: 100)
            let alert = UIAlertController(title: "Unsupported URL", message: urlContent, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
        }
        guard let comp = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            alertUnsupported()
            return
        }
        switch comp.host?.lowercased() {
        case "send":
            let chatID = comp.queryItems?.first(where: { $0.name == "id" })?.value
            if activeSession(chatID: chatID, from: scene) {
                //
            } else {
                rootViewController.tryActiveConversation(id: chatID)
            }
            if let sendText = comp.queryItems?.first(where: { $0.name == "text" })?.value {
                Current.conversationManager.send(text: sendText, toID: chatID)
            }
        default:
            alertUnsupported()
        }
    }

    /// True 成功执行
    private func activeSession(chatID: String?, from: UIScene) -> Bool {
        guard let chatID = chatID else { return false }
        guard let chatScene = UIApplication.shared.connectedScenes.first(where: {
            guard let activity = $0.userActivity,
                  activity.activityType == UserActivityType.conversation.rawValue else {
                return false
            }
            return activity.userInfo?["id"] as? String == chatID
        }) else { return false }

        let options = UIScene.ActivationRequestOptions()
        options.requestingScene = from
        UIApplication.shared.requestSceneSessionActivation(chatScene.session, userActivity: NSUserActivity(conversationID: chatID), options: options)
        return true
    }
}

protocol SceneEvent {
}
