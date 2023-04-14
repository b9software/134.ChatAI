//
//  MacBridge.swift
//  macBridge
//
//  Created by Joseph Zhao on 2023/4/4.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppKit

@objc(MacBridge)
class MacBridge: NSObject, MacInterface {
    required override init() {
    }

    var isAppActive: Bool {
        NSApp.isActive
    }

    var theme: Int {
        get {
            guard let name = NSApp.appearance?.name else {
                return 0
            }
            switch name {
            case .darkAqua:
                return 2
            case .aqua:
                return 1
            default:
                return 0
            }
        }
        set {
            switch newValue {
            case 1:
                NSApp.appearance = .init(named: .aqua)
            case 2:
                NSApp.appearance = .init(named: .darkAqua)
            default:
                NSApp.appearance = nil
            }
        }
    }

    func hideApp() {
        NSApp.hide(nil)
    }

    func beep() {
        NSSound.beep()
    }

    func sayHello() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Hello from AppKit!"
        alert.informativeText = "It Works!"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
