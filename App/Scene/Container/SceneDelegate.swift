//
//  SceneDelegate.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/19.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var rootViewController: RootViewController! {
        window?.rootViewController as? RootViewController
    }

    private(set) lazy var toolbarController = NSToolbarController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            toolbarController.windowTitleBar = titlebar
            toolbarController.update(additionalItems: [])
        }
        #endif
        /*
        switch AppUserDefaultsShared().preferredTheme {
        case 0:
            window?.overrideUserInterfaceStyle = .unspecified
        case 1:
            window?.overrideUserInterfaceStyle = .light
        case 2:
            window?.overrideUserInterfaceStyle = .dark
        default:
            break
        }
         */
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 200, height: 200)
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
        AppLog().debug("Scene> Active: \(scene.title ?? "?")")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        AppLog().debug("Scene> Resign active: \(scene.title ?? "?")")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        AppLog().debug("Scene> Background: \(scene.title ?? "?")")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        AppLog().debug("Scene> Open url \(URLContexts)")
    }

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
        AppLog().debug("Scene> UserActivity request state.")
        return scene.userActivity
    }

    func scene(_ scene: UIScene, restoreInteractionStateWith activity: NSUserActivity) {
        AppLog().debug("Scene> UserActivity restore interaction: \(activity).")
    }

    func scene(_ scene: UIScene, didUpdate activity: NSUserActivity) {
        AppLog().debug("Scene> UserActivity did update: \(activity).")
    }
}
