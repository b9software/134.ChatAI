/*
 B9Keychain

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation
import Security

enum B9Keychain {
    static var defaultService: String {
        Bundle.main.bundleIdentifier ?? "app.keychain"
    }

    static func string(account: String, service: String? = nil) throws -> String? {
        guard let data = try data(account: account, service: service) else {
            return nil
        }
        if let string = String(data: data, encoding: .utf8) { return string }
        AppLog().error("Unable covert data to UTF-8 string.")
        return nil
    }
    static func update(string: String?, account: String, service: String? = nil, label: String? = nil, comment: String? = nil) throws {
        try update(data: string?.data(using: .utf8), account: account, service: service, label: label, comment: comment)
    }

    static func data(account: String, service: String? = nil) throws -> Data? {
        var query = query(account: account, service: service)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        try check(status)
        return result as? Data
    }
    static func update(data: Data?, account: String, service: String? = nil, label: String? = nil, comment: String? = nil) throws {
        var query = query(account: account, service: service)
        if data == nil {
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecItemNotFound { return }
            try check(status)
            return
        }
        var changes = [CFString: Any]()
        changes[kSecValueData] = data
        if let value = label {
            changes[kSecAttrLabel] = value
        }
        if let value = comment {
            changes[kSecAttrComment] = value
        }
        var status = SecItemUpdate(query as CFDictionary, changes as CFDictionary)
        if status == errSecSuccess { return }
        if status == errSecItemNotFound {
            query.merge(changes) { (_, new) in new }
            status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess { return }
        }
        try check(status)
    }

    private static func query(account: String, service: String?) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service ?? Self.defaultService,
        ]
    }
    private static func check(_ status: OSStatus) throws {
        if status != errSecSuccess {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
