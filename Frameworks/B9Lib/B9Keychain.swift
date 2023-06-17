/*
 B9Keychain

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation
import Security

class B9Keychain {
    let defaultService: String

    init(service: String) {
        defaultService = service
    }

    func data(account: String) throws -> Data? {
        var query = query(account: account)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        try check(status)
        return result as? Data
    }
    func update(data: Data?, account: String, label: String? = nil, comment: String? = nil) throws {
        var query = query(account: account)
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

    private func query(account: String) -> [CFString: Any] {
        assertDispatch(.notOnQueue(.main))
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: defaultService,
        ]
    }
    private func check(_ status: OSStatus) throws {
        if status != errSecSuccess {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
