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
            UIKeyCommand(title: L.Menu.settingApp, action: #selector(ApplicationDelegate.gotoSetting), input: ",", modifierFlags: [.command]),
            UIKeyCommand(title: L.Menu.settingChat, action: #selector(StandardActions.gotoChatSetting), input: ",", modifierFlags: [.command, .shift]),
        ])
        builder.insertSibling(UIMenu(title: L.Menu.operation, children: [
            UIMenu(options: .displayInline, children: [
                UIKeyCommand(title: L.Menu.navigationBack, action: #selector(StandardActions.goBack), input: "[", modifierFlags: [.command])
            ]),
            UIKeyCommand(title: L.Menu.continueLastTopic, action: #selector(ConversationDetailViewController.toggleLastReply), input: "K", modifierFlags: [.command]),
            UIKeyCommand(title: L.Menu.focusInput, action: #selector(ConversationDetailViewController.focusInputBox), input: "L", modifierFlags: [.command]),
            UIKeyCommand(title: L.Menu.send, action: #selector(ConversationDetailViewController.onSend), input: "\r", modifierFlags: sendbyKey.keyModifierFlags),
        ]), afterMenu: .edit)
        #if targetEnvironment(macCatalyst)
        builder.insertSibling(buildFloatModeMenu(), beforeMenu: .minimizeAndZoom)
        #endif
        builder.replace(menu: .help, with: UIMenu(title: L.Menu.help, children: [
            UICommand(title: L.Menu.homePage, action: #selector(ApplicationDelegate.showHelp)),
            UICommand(title: L.Menu.userManual, action: #selector(ApplicationDelegate.showUserManual)),
            UICommand(title: L.Menu.feedback, action: #selector(ApplicationDelegate.showFeedback)),
        ]))
        builder.replace(menu: .preferences, with: settingItem)
        ApplicationDelegate().debug.setupMenu(builder: builder)
    }

    static func setNeedsRebuild() {
        AppLog().debug("Rebuild menu.")
        UIMenuSystem.main.setNeedsRebuild()
    }

    static func setNeedsRevalidate() {
        UIMenuSystem.main.setNeedsRevalidate()
    }

    static var sendbyKey: Sendby = .command {
        didSet {
            if oldValue == sendbyKey { return }
            setNeedsRebuild()
        }
    }

    static var keyWindowFloatModeState = FloatModeState.normal {
        didSet {
            if oldValue == keyWindowFloatModeState { return }
            setNeedsRebuild()
        }
    }

#if targetEnvironment(macCatalyst)
    static func buildFloatModeMenu() -> UIMenu {
        let children: [UIKeyCommand]
        switch keyWindowFloatModeState {
        case .normal:
            children = [
                UIKeyCommand(title: L.Menu.floatMode, action: #selector(ApplicationDelegate.enterFloatMode(_:)), input: "Y", modifierFlags: [.command]),
            ]
        case .floatExpand:
            children = [
                UIKeyCommand(title: L.Menu.floatModeCollapse, action: #selector(ApplicationDelegate.floatWindowCollapse(_:)), input: "Y", modifierFlags: [.command]),
                UIKeyCommand(title: L.Menu.floatModeExit, action: #selector(ApplicationDelegate.exitFloatMode(_:)), input: "Y", modifierFlags: [.command, .shift]),
            ]
        case .floatCollapse:
            children = [
                UIKeyCommand(title: L.Menu.floatModeExpand, action: #selector(ApplicationDelegate.floatWindowExpand(_:)), input: "Y", modifierFlags: [.command]),
                UIKeyCommand(title: L.Menu.floatModeExit, action: #selector(ApplicationDelegate.exitFloatMode(_:)), input: "Y", modifierFlags: [.command, .shift]),
            ]
        }
        return UIMenu(options: .displayInline, children: children)
    }
#endif
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
    @IBAction func goBack(_ sender: Any?) {}
    @IBAction func newConversation(_ sender: Any?) {}
    @IBAction func gotoChatSetting(_ sender: Any?) {}

    // NSApp
    @IBAction func hide(_ sender: Any?) {}
    @IBAction func newWindow(_ sender: Any?) {}
    @IBAction func newWindowForTab(_ sender: Any?) {}
}
