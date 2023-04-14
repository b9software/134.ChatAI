//
//  ApplicationMenu.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

enum ApplicationMenu {
    static func build(_ builder: UIMenuBuilder) {
        builder.remove(menu: .format)
        builder.replace(menu: .newScene, with: UIMenu(title: L.Menu.new, children: [
            UIKeyCommand(title: L.Menu.New.conversation, action: #selector(StandardActions.newConversation), input: "N", modifierFlags: .command, discoverabilityTitle: "New Conversation"),
            UIKeyCommand(title: L.Menu.New.tab, action: #selector(StandardActions.newWindowForTab(_:)), input: "T", modifierFlags: [.command], discoverabilityTitle: "New Window Tab"),
            UIKeyCommand(title: L.Menu.New.window, action: #selector(StandardActions.newWindow), input: "T", modifierFlags: [.command, .shift], discoverabilityTitle: "New Window"),
        ]))
        var settingItem = builder.menu(for: .preferences) ?? UIMenu(title: L.Menu.setting, identifier: .preferences, options: .displayInline)
        settingItem = settingItem.replacingChildren([
            UIKeyCommand(title: L.Menu.setting, action: #selector(ApplicationDelegate.gotoSetting), input: ",", modifierFlags: [.command]),
            UIKeyCommand(title: L.Menu.settingChat, action: #selector(StandardActions.gotoChatSetting), input: ",", modifierFlags: [.command, .shift]),
        ])
        builder.replace(menu: .help, with: UIMenu(title: "Help", children: [
            UICommand(title: L.Menu.homePage, action: #selector(ApplicationDelegate.showHelp)),
            UICommand(title: L.Menu.userManual, action: #selector(ApplicationDelegate.showUserManual)),
        ]))
        builder.replace(menu: .preferences, with: settingItem)
        ApplicationDelegate().debug.setupMenu(builder: builder)
    }

    static func setNeedsRebuild() {
        UIMenuSystem.main.setNeedsRebuild()
    }

    static func setNeedsRevalidate() {
        UIMenuSystem.main.setNeedsRevalidate()
    }
}

private extension ApplicationDelegate {
    @IBAction func gotoSetting(_ sender: Any) {
        let activity = NSUserActivity(.setting)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil)
    }

    @IBAction func newWindow(_ sender: Any?) {
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
    }
}

final class StandardActions {
    @IBAction func newConversation(_ sender: Any?) {}
    @IBAction func gotoChatSetting(_ sender: Any?) {}

    // NSApp
    @IBAction func hide(_ sender: Any?) {}
    @IBAction func newWindow(_ sender: Any?) {}
    @IBAction func newWindowForTab(_ sender: Any?) {}
}
