//
//  Engine.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

private let enginePool = ObjectPool<StringID, Engine>()

class Engine {
    private let entityID: NSManagedObjectID?
    var entity: CDEngine?

    init?(entity: CDEngine) {
        entityID = entity.objectID
        self.entity = entity
    }



}
