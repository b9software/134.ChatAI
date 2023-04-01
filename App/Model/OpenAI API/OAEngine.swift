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
        case keyHash = "k"
        case models = "m"
    }

    var apiKey: String?
    private var keyHash: String?
    var models: [OAModel]?
}

extension OAEngine {
    convenience init(id: StringID, models: [OAModel]) {
        self.init()
        self.keyHash = id
        self.models = models
    }
}
