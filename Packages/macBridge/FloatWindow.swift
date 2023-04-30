//
//  FloatWindow.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppKit
import ObjectiveC

class WindowStateObserver: NSObject {
    let window: NSWindow
    var keyObserver: NSKeyValueObservation!

    init(window: NSWindow) {
        self.window = window
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDefaultChange(notice:)), name: UserDefaults.didChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc private func handleUserDefaultChange(notice: Notification) {
        window.updateFloatDeactivceAplha()
    }
}

extension NSWindow {
    static var swizzle = false {
        didSet {
            if oldValue == swizzle { return }
            guard let originalMethod = class_getInstanceMethod(NSWindow.self, #selector(NSWindow.zoom(_:))),
                  let swizzledMethod = class_getInstanceMethod(NSWindow.self, #selector(NSWindow._b9_zoom(_:))) else {
                assert(false, "swizzle method nil")
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    static var floatDeactiveAlpha: CGFloat {
        UserDefaults.standard.value(forKey: "floatWindowAlpha") as? CGFloat ?? 0.2
    }

    static var floatCollapseSize: NSSize {
        NSSize(width: 200, height: 40)
    }

    static var floatExpandDefaultSize: NSSize {
        NSSize(width: 300, height: 500)
    }

    private var originalFrame: NSRect {
        get { originalFrameAssociation[self] ?? frame }
        set { originalFrameAssociation[self] = newValue }
    }

    private var expandFrame: NSRect {
        get {
            if let rect = expandFrameAssociation[self] {
                return rect
            }
            var rect = frame
            let defaultSize = Self.floatExpandDefaultSize
            if rect.size.width < defaultSize.width {
                rect.size.width = defaultSize.width
            }
            if rect.size.height < defaultSize.height {
                rect.size.height = defaultSize.height
            }
            return rect
        }
        set { expandFrameAssociation[self] = newValue }
    }

    private var isFloatExpand: Bool {
        get { isExpandAssociation[self] ?? isFloat }
        set { isExpandAssociation[self] = newValue }
    }

    var isFloat: Bool {
        get { level == .floating }
        set {
            if isFloat == newValue { return }
            if newValue {
                level = .floating
                styleMask = [.resizable, .titled, .closable]
                collectionBehavior.insert(.fullScreenNone)
                tabbingMode = .disallowed
                stateObserverAssociation[self] = WindowStateObserver(window: self)
            } else {
                level = .normal
                styleMask = [.borderless, .closable, .fullSizeContentView, .miniaturizable, .resizable, .titled]
                collectionBehavior.remove(.fullScreenNone)
                tabbingMode = .automatic
            }
        }
    }

    var floatState: FloatModeState {
        guard isFloat else { return .normal }
        return isFloatExpand ? .floatExpand : .floatCollapse
    }

    func setFloatMode(_ state: FloatModeState, animated: Bool) {
        if floatState == state { return }
        debugPrint("Window> set state \(state)")
        noticeFloatWillChange(to: state)
        if state == .normal {
            isFloat = false
            setFrame(originalFrame, display: true, animate: animated)
            noticeFloatDidChange(to: state)
            return
        }
        if tabGroup?.isOverviewVisible == true {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0
                animator().toggleTabOverview(nil)
            }, completionHandler: {
                self.makeFloat(state, animated: animated)
            })
            return
        }
        makeFloat(state, animated: animated)
    }

    private func makeFloat(_ state: FloatModeState, animated: Bool) {
        if !isFloat {
            if tabbedWindows?.count ?? 0 > 1 {
                moveTabToNewWindow(self)
            }
            if tabGroup?.isTabBarVisible == true {
                toggleTabBar(self)
            }
            if styleMask.contains(.fullScreen) {
                toggleFullScreen(self)
            }
            isFloat = true
            var rect = frame
            originalFrame = rect
            rect.size = Self.floatExpandDefaultSize
            expandFrame = rect
            setFrame(rect, display: true, animate: animated)
        }
        if state == .floatExpand {
            setFrame(expandFrame, display: true, animate: animated)
            isFloatExpand = true
        }
        if state == .floatCollapse {
            expandFrame = frame
            var rect = frame
            rect.size = Self.floatCollapseSize
            setFrame(rect, display: true, animate: animated)
            minSize = rect.size
            maxSize = rect.size
            isFloatExpand = false
        } else {
            minSize = NSSize(width: 200, height: 200)
            maxSize = NSSize(width: .max, height: .max)
        }
        noticeFloatDidChange(to: state)
    }

    private func noticeFloatWillChange(to state: FloatModeState) {
        NotificationCenter.default.post(name: .floatModeDidChange, object: self, userInfo: ["state": state.rawValue])
        assert(state != floatState)
    }

    private func noticeFloatDidChange(to state: FloatModeState) {
        NotificationCenter.default.post(name: .floatModeDidChange, object: self, userInfo: ["state": state.rawValue])
        assert(state == floatState)
    }

    func updateFloatDeactivceAplha() {
        var newAlpha = alphaValue
        if isFloat, !isKeyWindow {
            if let event = NSApp.currentEvent,
               event.window === self {
                if event.type == .mouseEntered {
                    newAlpha = 1
                }
                if event.type == .mouseExited {
                    newAlpha = NSWindow.floatDeactiveAlpha
                }
            } else {
                newAlpha = NSWindow.floatDeactiveAlpha
            }
        } else {
            newAlpha = 1
        }
        if abs(alphaValue - newAlpha) > 0.05 {
            animator().alphaValue = newAlpha
        }
    }

    @objc func _b9_zoom(_ sender: Any?) {
        if isFloat {
            if floatState == .floatExpand {
                setFloatMode(.floatCollapse, animated: true)
            } else {
                setFloatMode(.floatExpand, animated: true)
            }
            return
        }
        _b9_zoom(sender)
    }
}
private let stateObserverAssociation = AssociatedObject<WindowStateObserver>()
private let isExpandAssociation = AssociatedObject<Bool>()
private let originalFrameAssociation = AssociatedObject<NSRect>()
private let expandFrameAssociation = AssociatedObject<NSRect>()

final class AssociatedObject<T> {
    private let policy: objc_AssociationPolicy

    init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }
    subscript(index: AnyObject) -> T? {
        get {
            objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T
        }
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
        }
    }
}
