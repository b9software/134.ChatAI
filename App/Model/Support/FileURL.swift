//
//  FileURL.swift
//  App
//

import CoreData

/**
 文件路径集中管理
 */
enum FileURL {
    // swiftlint:disable:next force_try
    static let supportDirectory: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

    static let database: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("app.db")
}
