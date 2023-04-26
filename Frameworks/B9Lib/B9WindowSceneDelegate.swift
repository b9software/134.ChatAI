//
//  B9WindowSceneDelegate.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9MulticastDelegate
import UIKit

class B9WindowSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private(set) lazy var eventListener = MulticastDelegate<UIWindowSceneDelegate>()

    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    func sceneDidEnterBackground(_ scene: UIScene) {
        eventListener.invoke {
            $0.sceneDidEnterBackground?(scene)
        }
    }
}
