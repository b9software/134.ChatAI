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
        let items: [CDEngine]? = Current.database.context.fetch(request)
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

    func delete() {
        AppLog().debug("Engine> Delete \(objectID)...")
        guard let ctx = managedObjectContext else {
            assert(false)
            return
        }
        ctx.perform {
            let idCopy = self.id
            ctx.delete(self)
            ctx.trySave()
            guard let account = idCopy else {
                assert(false)
                return
            }
            Do.try {
                try B9Keychain.update(data: nil, account: account)
            }
            AppLog().info("Engine> Delete \(account) success.")
        }
    }
}
