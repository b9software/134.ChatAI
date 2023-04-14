//
//  MacInterface.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/4.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

@objc(MacInterface)
protocol MacInterface: NSObjectProtocol {
    init()

    var isAppActive: Bool { get }

    var theme: Int { get set }

    func hideApp()

    /// Plays the system beep.
    func beep()
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

class MockedMacInterface: NSObject, MacInterface {
    required override init() {
        super.init()
    }

    var isAppActive = false
    var theme: Int = 0

    func hideApp() {}
    func beep() {}

    func sayHello() {}
}
