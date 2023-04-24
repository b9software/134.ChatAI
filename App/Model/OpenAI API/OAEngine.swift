//
//  OAEngine.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/3/31.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

/// App only model
class OAEngine: Codable, CustomDebugStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case models = "m"
        case modelLastUsed = "ml"
        case modelLastFetchTime = "mt"
        case baseURL = "cb"
        case customListModelURL = "cm"
        case customCompletionURL = "cc"
    }

    var models: [OAModel]?
    var modelLastUsed: StringID?
    var modelLastFetchTime: Date?

    var baseURL: URL?
    var customListModelURL: URL?
    var customCompletionURL: URL?

    /// Memory only
    var apiKey: String?
}

extension OAEngine {
    convenience init(models: [OAModel]) {
        self.init()
        self.models = models
    }
}
