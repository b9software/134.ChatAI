//
//  TestCase.swift
//  UnitTests
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI
import XCTest

class TestCase: XCTestCase {
    struct ResetPoint: OptionSet {
        let rawValue: Int

        static let setUp = ResetPoint(rawValue: 1 << 0)
        static let tearDown = ResetPoint(rawValue: 1 << 1)
        static let setUpClass = ResetPoint(rawValue: 1 << 2)
        static let tearDownClass = ResetPoint(rawValue: 1 << 3)
    }

    class var mockResetPoint: ResetPoint {
        []
    }

    /// Overwrite this property to save and reset UserDefaults keys at tests setup
    /// and restore them to original ones after tests tear down
    class var coverUserDefaultsKeys: [String] {
        []
    }

    private static var restoreDefaultValues = [String: Any?]()

    override class func setUp() {
        super.setUp()
        if mockResetPoint.contains(.setUpClass) {
            Mocked.reset()
        }
        restoreDefaultValues.removeAll()
        for key in coverUserDefaultsKeys {
            let value = UserDefaults.standard.object(forKey: key)
            restoreDefaultValues[key] = value
            if value != nil {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    override class func tearDown() {
        super.tearDown()
        if mockResetPoint.contains(.tearDownClass) {
            Mocked.reset()
        }
        for (key, value) in restoreDefaultValues {
            if let value = value {
                UserDefaults.standard.set(value, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        restoreDefaultValues.removeAll()
    }

    override func setUp() {
        super.setUp()
        if Self.mockResetPoint.contains(.setUp) {
            Mocked.reset()
        }
    }

    override func tearDown() {
        super.tearDown()
        if Self.mockResetPoint.contains(.tearDown) {
            Mocked.reset()
        }
    }
}
