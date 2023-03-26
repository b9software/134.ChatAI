//
//  OAModel.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name

struct OAModel: Codable, ModelValidate {
    private(set) var id: StringID
    private(set) var object: String = "model"
    private(set) var created: Timestamp?
    private(set) var owned_by: String?
    private(set) var root: String?
    private(set) var parent: StringID?

    func validate() throws {
        if object != "model" {
            throw ModelError.invalid("Not a model object.")
        }
    }

    /// 是否是可以用于 Chat 调用的模型
    var isChatMode: Bool {
        id.hasPrefix("gpt-") || parent?.hasPrefix("gpt-") == true
    }
}
