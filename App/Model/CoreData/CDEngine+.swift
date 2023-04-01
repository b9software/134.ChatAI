//
//  CDEngine+.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

extension CDEngine {

    static func fetch(id: StringID) -> CDEngine? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let items: [CDEngine]? = AppDatabase().context.fetch(request)
        return items?.first
    }

    static var listRequest: NSFetchRequest<CDEngine> {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDEngine.usedTime), ascending: false),
            NSSortDescriptor(key: #keyPath(CDEngine.createTime), ascending: false)
        ]
        return request
    }
}
