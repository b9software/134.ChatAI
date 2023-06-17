//
//  KeychainAccess.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

protocol KeychainAccess {
    func data(account: String) throws -> Data?

    func update(data: Data?, account: String, label: String?, comment: String?) throws
}

extension KeychainAccess {
    func string(account: String) throws -> String? {
        guard let data = try data(account: account) else {
            return nil
        }
        if let string = String(data: data, encoding: .utf8) { return string }
        AppLog().error("Unable covert data to UTF-8 string.")
        return nil
    }
    func update(string: String?, account: String, label: String? = nil, comment: String? = nil) throws {
        try update(data: string?.data(using: .utf8), account: account, label: label, comment: comment)
    }

    func update(data: Data?, account: String) throws {
        try update(data: data, account: account, label: nil, comment: nil)
    }
}

extension B9Keychain: KeychainAccess {
}
