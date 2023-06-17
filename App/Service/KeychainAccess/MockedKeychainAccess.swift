//
//  MockedKeychainAccess.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

@testable import B9ChatAI

class MockedKeychainAccess: KeychainAccess {
    var storage = [String: Data]()

    func data(account: String) throws -> Data? {
        storage[account]
    }

    func update(data: Data?, account: String, label: String?, comment: String?) throws {
        storage[account] = data
    }
}
