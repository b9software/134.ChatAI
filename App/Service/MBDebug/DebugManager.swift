//
//  DebugManager.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/19.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

final class DebugManager {

    func setupMenu(builder: UIMenuBuilder) {
        #if DEBUG
        let menu = UIMenu(title: "Developer", children: [
            UICommand(title: "Rebuild Menu", action: #selector(ApplicationDelegate.debugRebuildMenu(_:))),
            UICommand(title: "Test 2", action: #selector(ApplicationDelegate.onTest2)),
            UICommand(title: "Debug Window", action: #selector(ApplicationDelegate.debugWindow)),
            UICommand(title: "Debug Menu & Toolbar", action: #selector(ApplicationDelegate.debugSystemUISwitch(_:)), state: debugSystemUI ? .on : .off),
            UICommand(title: "Debug Responder", action: #selector(ApplicationDelegate.debugResponderSwitch(_:)), state: debugResponder ? .on : .off),
        ])
        builder.insertSibling(menu, afterMenu: .window)
        #endif
    }

    var debugSystemUI: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    var debugResponder: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
}

#if DEBUG
private extension ApplicationDelegate {
    @IBAction func debugRebuildMenu(_ sender: Any) {
        ApplicationMenu.setNeedsRebuild()
    }

    @IBAction func onTest2(_ sender: Any) {
        debugPrint(UIApplication.shared.connectedScenes)
    }

    @IBAction func debugWindow(_ sender: Any) {
        print("Windows: \(UIApplication.shared.windows)")
        print("Key win: \(UIApplication.shared.keyWindow)")
        print("Scenes: \(UIApplication.shared.connectedScenes)")
        print("Scenes(open): \(UIApplication.shared.openSessions)")
//        var activity = NSUserActivity(activityType: "panel")
//        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
//        }
    }

    @IBAction func debugSystemUISwitch(_ sender: Any) {
        debug.debugSystemUI.toggle()
        ApplicationMenu.setNeedsRebuild()
    }

    @IBAction func debugResponderSwitch(_ sender: Any) {
        debug.debugResponder.toggle()
        ApplicationMenu.setNeedsRebuild()
    }
}
#endif

extension UIMenu.Identifier {
    static var developer: UIMenu.Identifier { UIMenu.Identifier("app.menu.developer") }
}
