//
//  DebugManager.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/19.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Security
import UIKit

final class DebugManager {
#if DEBUG
    func setupMenu(builder: UIMenuBuilder) {
        let menu = UIMenu(title: "Developer", children: [
            UICommand(title: "Rebuild Menu", action: #selector(ApplicationDelegate.debugRebuildMenu)),
            UICommand(title: "Test 2", action: #selector(ApplicationDelegate.onTest2)),
            UICommand(title: "Dump DB", action: #selector(ApplicationDelegate.debugDumpDatabase)),
            UICommand(title: "Engine no key", action: #selector(ApplicationDelegate.debugEngineCreateWithNoKey)),
            UICommand(title: "Engine invalid key", action: #selector(ApplicationDelegate.debugEngineCreateWithInvalidKey)),
            UICommand(title: "Destroy Conversations", action: #selector(ApplicationDelegate.debugDestroyConversation)),
            UICommand(title: "Debug Window", action: #selector(ApplicationDelegate.debugWindow)),
            UICommand(title: "Debug Menu & Toolbar", action: #selector(ApplicationDelegate.debugSystemUISwitch), state: debugSystemUI ? .on : .off),
            UICommand(title: "Debug Responder", action: #selector(ApplicationDelegate.debugResponderSwitch), state: debugResponder ? .on : .off),
        ])
        builder.insertSibling(menu, afterMenu: .window)
    }

    var debugSystemUI: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    var debugResponder: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
#else
    func setupMenu(builder: UIMenuBuilder) {}

    let debugResponder = false
#endif
}

#if DEBUG
fileprivate extension ApplicationDelegate {
    @objc func debugRebuildMenu() {
        ApplicationMenu.setNeedsRebuild()
    }

    @objc func onTest2() {
//        debugPrint(UIApplication.shared.connectedScenes)
    }

    @objc func debugWindow() {
        print("Windows: \(UIApplication.shared.windows)")
        print("Key win: \(UIApplication.shared.keyWindow)")
        print("Scenes: \(UIApplication.shared.connectedScenes)")
        print("Scenes(open): \(UIApplication.shared.openSessions)")
//        var activity = NSUserActivity(activityType: "panel")
//        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error) in
//        }
    }

    @objc func debugSystemUISwitch() {
        debug.debugSystemUI.toggle()
        ApplicationMenu.setNeedsRebuild()
    }

    @objc func debugResponderSwitch() {
        debug.debugResponder.toggle()
        ApplicationMenu.setNeedsRebuild()
    }

    @objc func debugDumpDatabase() {
        Current.database.dump()
    }

    @objc func debugEngineCreateWithNoKey() {
        CDEngine.debugCreateWithNoKey()
    }

    @objc func debugEngineCreateWithInvalidKey() {
        CDEngine.debugCreateWithInvalidKey()
    }

    @objc func debugDestroyConversation() {
        let ctx = Current.database.viewContext
        try? ctx.fetch(CDConversation.fetchRequest()).forEach { ctx.delete($0) }
        ctx.trySave()
    }
}
#endif

extension UIMenu.Identifier {
    static var developer: UIMenu.Identifier { UIMenu.Identifier("app.menu.developer") }
}
