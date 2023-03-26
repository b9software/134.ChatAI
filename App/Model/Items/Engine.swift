//
//  Engine.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

private let enginePool = ObjectPool<StringID, Engine>()

actor Engine {
    enum EType: String {
    case openAI = "OpenAI"
    case openAIProxy = "OpenAI Proxy"
    }

    private let entityID: NSManagedObjectID?
    var entity: CDEngine?
    let type: EType
    var oaEngine: OAEngine! {
        didSet {
            Do.try {
                entity?.raw = try JSONEncoder().encode(oaEngine)
            }
        }
    }

    init(entity: CDEngine) throws {
        entityID = entity.objectID
        guard let type = EType(rawValue: entity.type ?? "") else {
            throw AppError.message("Engine> init with invalid type: \(entity.type ?? "nil").")
        }
        self.type = type
        self.entity = entity
        switch type {
        case .openAI:
            guard let raw = entity.raw else {
                throw AppError.message("Engine> init with nil raw.")
            }
            oaEngine = try OAEngine.decode(raw)
        case .openAIProxy:
            fatalError("todo")
        }
    }
}
