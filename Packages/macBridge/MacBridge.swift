//
//  MacBridge.swift
//  macBridge
//
//  Created by Joseph Zhao on 2023/4/4.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppKit
import ObjectiveC

@objc(MacBridge)
final class MacBridge: NSObject, MacInterface {

    required override init() {
        NSWindow.swizzle = true
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

    // MARK: - Float Window

    var keyWindowFloatMode: Int {
        get {
            NSApp.keyWindow?.floatState.rawValue ?? 0
        }
        set {
            guard let state = FloatModeState(rawValue: newValue),
                  let window = NSApp.keyWindow else {
                return
            }
            window.setFloatMode(state, animated: true)
        }
    }

    var keyWindowChangeObserver: (() -> Void)? {
        didSet {
            observeNSKeyWindow = keyWindowChangeObserver != nil
        }
    }

    private var mouseMonitor: Any?
    private var observeNSKeyWindow = false {
        didSet {
            if oldValue == observeNSKeyWindow { return }
            let nc = NotificationCenter.default
            if observeNSKeyWindow {
                nc.addObserver(self, selector: #selector(windowDidBecomeKey(notice:)), name: NSWindow.didBecomeKeyNotification, object: nil)
                nc.addObserver(self, selector: #selector(windowDidResignKey(notice:)), name: NSWindow.didResignKeyNotification, object: nil)
                mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseEntered, .mouseExited], handler: handleMouseEvent(event:))
            } else {
                nc.removeObserver(self, name: NSWindow.didBecomeKeyNotification, object: nil)
                nc.removeObserver(self, name: NSWindow.didResignKeyNotification, object: nil)
                if let monitor = mouseMonitor {
                    NSEvent.removeMonitor(monitor)
                    mouseMonitor = nil
                }
            }
        }
    }
    @objc private func windowDidBecomeKey(notice: Notification) {
        debugPrint(notice)
        keyWindowChangeObserver?()
        (notice.object as? NSWindow)?.updateFloatDeactivceAplha()
    }
    @objc private func windowDidResignKey(notice: Notification) {
        debugPrint(notice)
        keyWindowChangeObserver?()
        (notice.object as? NSWindow)?.updateFloatDeactivceAplha()
    }
    private func handleMouseEvent(event: NSEvent) -> NSEvent? {
        event.window?.updateFloatDeactivceAplha()
        return event
    }
}

// MARK: - Float Mode


extension NSWindow.StyleMask: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = [String]()
        if contains(.borderless) {
            desc.append(".borderless")
        }
        if contains(.closable) {
            desc.append(".closable")
        }
        if contains(.docModalWindow) {
            desc.append(".docModalWindow")
        }
        if contains(.fullScreen) {
            desc.append(".fullScreen")
        }
        if contains(.fullSizeContentView) {
            desc.append(".fullSizeContentView")
        }
        if contains(.hudWindow) {
            desc.append(".hudWindow")
        }
        if contains(.miniaturizable) {
            desc.append(".miniaturizable")
        }
        if contains(.nonactivatingPanel) {
            desc.append(".nonactivatingPanel")
        }
        if contains(.resizable) {
            desc.append(".resizable")
        }
        if contains(.titled) {
            desc.append(".titled")
        }
        if contains(.unifiedTitleAndToolbar) {
            desc.append(".unifiedTitleAndToolbar")
        }
        if contains(.utilityWindow) {
            desc.append(".utilityWindow")
        }
        if contains(.texturedBackground) {
            desc.append(".texturedBackground")
        }
        return "[" + desc.joined(separator: ", ") + "]"
    }
}
