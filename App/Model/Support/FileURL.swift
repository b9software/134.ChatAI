//
//  FileURL.swift
//  App
//

/**
 文件路径集中管理
 */
enum FileURL {
    // swiftlint:disable:next force_try
    static var supportDirectory: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
}
