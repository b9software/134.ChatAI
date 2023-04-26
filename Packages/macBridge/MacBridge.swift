//
//  MacBridge.swift
//  macBridge
//
//  Created by Joseph Zhao on 2023/4/4.
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppKit

@objc(MacBridge)
final class MacBridge: NSObject, MacInterface {
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

    // MARK: - Float Window

    var floatWindowDeactivateAlpha: CGFloat = 0.2

    var keyWindowIsInFloatMode: Bool {
        NSApp.keyWindow?.level == .floating
    }

    func floatWindow() {
        guard let window = NSApp.keyWindow else {
            return
        }
        if window.tabGroup?.isOverviewVisible == true {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0
                window.animator().toggleTabOverview(nil)
            }, completionHandler: {
                if let window = NSApp.keyWindow {
                    self.makeFloat(window: window)
                }
            })
            return
        }
        makeFloat(window: window)
    }

    private func makeFloat(window: NSWindow) {
        if window.tabbedWindows?.count ?? 0 > 1 {
            window.moveTabToNewWindow(nil)
        }
        if window.tabGroup?.isTabBarVisible == true {
            window.toggleTabBar(nil)
        }
        window.tabbingMode = .disallowed

        if window.styleMask.contains(.fullScreen) {
            window.toggleFullScreen(nil)
        }
        window.styleMask = [.resizable, .titled, .closable]
        window.level = .floating
        window.collectionBehavior.insert(.fullScreenNone)
        floatWindowStates[window] = FloatWindowState()

        guard let screen = window.screen else {
            assert(false)
            return
        }
        debugPrint("screen.frame", screen.frame)
        debugPrint("screen.visibleFrame", screen.visibleFrame)
        debugPrint(window.contentView)
        debugPrint(window.contentViewController)
        var frame = window.frame
        floatWindowStates[window]?.originalFrame = frame
        frame.size = NSSize(width: 300, height: 500)
        window.setFrame(frame, display: true, animate: true)
    }

    func unfloatWindow() {
        guard let window = NSApp.keyWindow else {
            return
        }
        window.styleMask = defaultWindowStyle
        window.level = .normal
        let state = floatWindowStates.removeValue(forKey: window)
        if let frame = state?.originalFrame {
            window.setFrame(frame, display: true, animate: true)
        }
        window.tabbingMode = .automatic
        window.collectionBehavior.remove(.fullScreenNone)
    }

    private class FloatWindowState {
        var isExpand = true
        var originalFrame: NSRect = .null
    }

    private var floatWindowStates = [NSWindow: FloatWindowState]()

    var keyWindowIsFloatExpand: Bool {
        get {
            guard let window = NSApp.keyWindow else {
                return false
            }
            return floatWindowStates[window]?.isExpand ?? false
        }
        set {
            guard let window = NSApp.keyWindow else {
                assert(false)
                return
            }
            let state = floatWindowStates[window] ?? {
                let newState = FloatWindowState()
                floatWindowStates[window] = newState
                return newState
            }()
            state.isExpand = newValue
        }
    }

    private var defaultWindowStyle: NSWindow.StyleMask {
        [.borderless, .closable, .fullSizeContentView, .miniaturizable, .resizable, .titled]
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
    }
    @objc private func windowDidResignKey(notice: Notification) {
        debugPrint(notice)
        keyWindowChangeObserver?()
        if let window = notice.object as? NSWindow,
           window.level == .floating,
           let location = NSApp.currentEvent?.locationInWindow {
            if !window.frame.contains(location) {
                window.animator().alphaValue = floatWindowDeactivateAlpha
            }
        }
    }
    private func handleMouseEvent(event: NSEvent) -> NSEvent? {
        if let window = event.window,
           window.level == .floating {
            if event.type == .mouseExited {
                if !window.isKeyWindow {
                    window.animator().alphaValue = floatWindowDeactivateAlpha
                }
            } else if event.type == .mouseEntered {
                window.animator().alphaValue = 1
            }
        }
        return event
    }
}

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
