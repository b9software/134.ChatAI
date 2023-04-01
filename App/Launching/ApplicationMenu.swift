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
            UIKeyCommand(title: L.Menu.New.conversation, action: #selector(ApplicationDelegate.newConversation), input: "N", modifierFlags: .command, discoverabilityTitle: "New Conversation"),
            UIKeyCommand(title: L.Menu.New.tab, action: #selector(NSStandardActions.newWindowForTab(_:)), input: "T", modifierFlags: [.command], discoverabilityTitle: "New Window Tab"),
            UIKeyCommand(title: L.Menu.New.window, action: #selector(ApplicationDelegate.newWindow), input: "T", modifierFlags: [.command, .shift], discoverabilityTitle: "New Window"),
        ]))
        ApplicationDelegate().debug.setupMenu(builder: builder)
    }

    static func setNeedsRebuild() {
        UIMenuSystem.main.setNeedsRebuild()
    }
}

private extension ApplicationDelegate {
    @IBAction func newConversation(_ sender: Any) {
        debugPrint(#function)
    }

    @IBAction func newWindow(_ sender: Any) {
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil) { (error) in
            //
        }
    }
}


final class NSStandardActions {
    @IBAction func newWindowForTab(_ sender: Any?) {}
}
