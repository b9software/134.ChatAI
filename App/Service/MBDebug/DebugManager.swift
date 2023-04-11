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
            UICommand(title: "Dump Sender", action: #selector(ApplicationDelegate.debugLogSender)),
            UICommand(title: "Engine no key", action: #selector(ApplicationDelegate.debugEngineCreateWithNoKey)),
            UICommand(title: "Engine invalid key", action: #selector(ApplicationDelegate.debugEngineCreateWithInvalidKey)),
            UICommand(title: "Destroy Conversations", action: #selector(ApplicationDelegate.debugDestroyConversation)),
            UICommand(title: "Debug Window", action: #selector(ApplicationDelegate.debugWindow)),
            UICommand(title: "Debug Menu & Toolbar", action: #selector(ApplicationDelegate.debugSystemUISwitch), state: debugSystemUI ? .on : .off),
            UICommand(title: "Listen Focus Update", action: #selector(ApplicationDelegate.debugListenFocus), state: debugListenFocus ? .on : .off),
            UICommand(title: "Log Responder Chain", action: #selector(ApplicationDelegate.debugResponderChain)),
            UICommand(title: "Debug Action Target", action: #selector(ApplicationDelegate.debugResponderSwitch), state: debugResponder ? .on : .off),
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

    var debugListenFocus: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
#else
    func setupMenu(builder: UIMenuBuilder) {}

    let debugResponder = false
#endif
}

#if DEBUG
private var focusSystemUpdateObserver: NSObjectProtocol?
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

    @objc func debugListenFocus() {
        debug.debugListenFocus.toggle()
        if debug.debugListenFocus {
            focusSystemUpdateObserver = NotificationCenter.default.addObserver(forName: UIFocusSystem.didUpdateNotification, object: nil, queue: nil) { notice in
                // swiftlint:disable:next force_cast
                let itemDesc = (notice.object as! UIFocusSystem).focusedItem?.description ?? "nil"
                AppLog().debug("\(notice.name.rawValue): \(itemDesc)")
            }
        } else {
            NotificationCenter.default.removeObserver(focusSystemUpdateObserver as Any)
        }
    }

    @objc func debugResponderSwitch() {
        debug.debugResponder.toggle()
        ApplicationMenu.setNeedsRebuild()
    }

    @objc func debugResponderChain() {
        var first: UIResponder? = UIResponder.firstResponder
        print("First Responder: \(first?.description ?? "nil")")
        while first != nil {
            if let obj = first {
                print("   | \(obj.description)")
            }
            first = first?.next
        }
    }

    @objc func debugDumpDatabase() {
        Current.database.dump()
    }

    @objc func debugLogSender() {
        Task {
            await Current.messageSender.logDebugDescription()
        }
    }

    @objc func debugEngineCreateWithNoKey() {
        CDEngine.debugCreateWithNoKey()
    }

    @objc func debugEngineCreateWithInvalidKey() {
        CDEngine.debugCreateWithInvalidKey()
    }

    @objc func debugDestroyConversation() {
        Current.database.save { ctx in
            try? ctx.fetch(CDConversation.fetchRequest()).forEach { ctx.delete($0) }
        }
    }
}
#endif

extension UIMenu.Identifier {
    static var developer: UIMenu.Identifier { UIMenu.Identifier("app.menu.developer") }
}
