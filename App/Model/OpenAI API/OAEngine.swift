//
//  OAEngine.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/3/31.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

class OAEngine: Codable {
    private enum CodingKeys: String, CodingKey {
        case keyHash = "k"
        case models = "m"
    }

    var apiKey: String?
    private var keyHash: String?
    var models: [OAModel]?

    func create() -> Task<Void, Error> {
        Task {

        }
    }
}
