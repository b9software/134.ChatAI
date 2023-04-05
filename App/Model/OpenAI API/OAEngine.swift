//
//  OAEngine.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/3/31.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

/// App only model
class OAEngine: Codable {
    private enum CodingKeys: String, CodingKey {
        case models = "m"
        case modelLastUsed = "ml"
        case modelLastFetchTime = "mt"
    }

    var models: [OAModel]?
    var modelLastUsed: StringID?
    var modelLastFetchTime: Date?

    /// Memory only
    var apiKey: String?
}

extension OAEngine {
    convenience init(models: [OAModel]) {
        self.init()
        self.models = models
    }
}
