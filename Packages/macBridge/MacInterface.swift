//
//  MacInterface.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

enum FloatModeState: Int {
    case normal = 1
    case floatExpand = 2
    case floatCollapse = 3

    var isFloat: Bool {
        self != .normal
    }
}

@objc(MacInterface)
protocol MacInterface: NSObjectProtocol {
    init()

    var isAppActive: Bool { get }

    var theme: Int { get set }

    func hideApp()

    /// Plays the system beep.
    func beep()

    /// Values:
    /// - 0 no key window
    /// - 1 has key normal
    /// - 2 float expand
    /// - 3 float collapse
    var keyWindowFloatMode: Int { get set }

    var keyWindowChangeObserver: (() -> Void)? { get set }
}

#if targetEnvironment(macCatalyst)

extension MacInterface {
    static func load() -> MacInterface? {
        guard let url = Bundle.main.builtInPlugInsURL?.appendingPathComponent("macBridge.bundle"),
              let bridgeBundle = Bundle(url: url) else {
            print("[Error] Unable find bridge bundle.")
            return nil
        }
        guard let bridgeClass = bridgeBundle.principalClass as? MacInterface.Type else {
            print("[Error] Unable load bridge class.")
            return nil
        }
        return bridgeClass.init()
    }
}

#endif

extension Notification.Name {
    static let floatModeWillChange = Notification.Name("app.window.floatModeWillChange")
    static let floatModeDidChange = Notification.Name("app.window.floatModeChanged")
}

class MockedMacInterface: NSObject, MacInterface {
    required override init() {
        super.init()
    }

    var isAppActive = false
    var theme: Int = 0
    var keyWindowFloatMode = 0
    var keyWindowChangeObserver: (() -> Void)?

    func hideApp() {}
    func beep() {}
}
