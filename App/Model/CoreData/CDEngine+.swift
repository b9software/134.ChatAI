//
//  CDEngine+.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppFramework
import CoreData

extension CDEngine {

    static func fetch(id: StringID) async -> CDEngine? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        let items: [CDEngine]? = await Current.database.read {
            try? $0.fetch(request)
        }
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
        modify { this, ctx in
            let idCopy = this.id
            ctx.delete(this)
            if let account = idCopy {
                Do.try {
                    try Current.keychain.update(data: nil, account: account)
                }
            }
            AppLog().info("Engine> Delete \(idCopy ?? "?") success.")
        }
    }

    func loadOAEngine() throws -> OAEngine {
        guard let raw = self.raw else {
            throw AppError.message("Engine> init with nil raw.")
        }
        let oaEngine = try OAEngine.decode(raw)
        if let id = self.id {
            oaEngine.apiKey = try Current.keychain.string(account: id)
        }
        return oaEngine
    }

    func save(oaEngine: OAEngine) {
        modify { this, _ in
            // Encode won't fail
            this.raw = try? oaEngine.encode()
        }
    }
}

#if DEBUG
// swiftlint:disable all
extension CDEngine {
    static func debugCreateWithNoKey() {
        Current.database.save { ctx in
            let engine = CDEngine(context: ctx)
            engine.id = "OA-No key"
            engine.name = "No Key"
            engine.type = Engine.EType.openAI.rawValue
            let item = OAEngine(models: [])
            engine.raw = try! item.encode()
        }
    }

    static func debugCreateWithInvalidKey() {
        Current.database.save { ctx in
            let engine = CDEngine(context: ctx)
            engine.id = "OA-Invalid"
            try! Current.keychain.update(string: "Invalid", account: engine.id!)
            engine.name = "Invalid Key"
            engine.type = Engine.EType.openAI.rawValue
            let item = OAEngine(models: [])
            engine.raw = try! item.encode()
        }
    }
}
// swiftlint:enable all
#endif
