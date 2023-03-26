//
//  DBManager.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

/// 数据库单例
func AppDatabase() -> DBManager {  // swiftlint:disable:this identifier_name
    DBManager.shared ?? DBManager.setup()
}

/**
 注意：在远端修改后 UI 与内存中的状态同步

 Guide:
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html
 https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/creating_a_core_data_model_for_cloudkit
 */
class DBManager {
    typealias CDContainer = NSPersistentCloudKitContainer

    fileprivate static var shared: DBManager?
    static var loadedModel: NSManagedObjectModel?

    @discardableResult
    static func setup(test: Bool = false) -> DBManager {
        let container: CDContainer
        if let model = loadedModel {
            container = CDContainer(name: "CD", managedObjectModel: model)
        } else {
            container = CDContainer(name: "CD")
        }
        let useCloud = UserDefaults.standard.iCloudEnable
        let description = NSPersistentStoreDescription()
        if test {
            description.type = NSInMemoryStoreType
        }
        description.configuration = useCloud ? "Cloud" : "Default"
        container.persistentStoreDescriptions = [description]
        #if DEBUG
        do {
            if useCloud {
                try container.initializeCloudKitSchema(options: [])
                AppLog().info("DB> Initialize CloudKit schema.")
            }
        } catch {
            AppLog().error("DB> Init cloud schema fail: \(error)")
        }
        #endif
        container.loadPersistentStores { store, err in
            AppLog().debug("DB> Store loaded at: \(store.url?.path ?? "null.")")
            if let err = err {
                fatalError(err.localizedDescription)
            }
        }
        let instance = DBManager(container: container)
        shared = instance
        loadedModel = container.managedObjectModel
        return instance
    }

    let dbQueue = DispatchQueue(label: "app.database", qos: .userInitiated)
    let container: CDContainer
    let context: CDContext

    init(container: CDContainer) {
        self.container = container
        self.context = CDContext(ctx: container.newBackgroundContext())
    }
}

actor CDContext {
    let ctx: NSManagedObjectContext
    private(set) var lastError: Error? {
        didSet {
            if let err = lastError {
                AppLog().error("DB> Error: \(err)")
            }
        }
    }

    fileprivate init(ctx: @autoclosure () -> NSManagedObjectContext) {
        self.ctx = ctx()
    }

    /// Return `nil` when failed.
    func fetch<T>(_ request: NSFetchRequest<T>) -> [T]? where T: NSFetchRequestResult {
        ctx.performAndWait {
            do {
                return try ctx.fetch(request)
            } catch {
                lastError = error
                return nil
            }
        }
    }

    func save() {
        ctx.performAndWait {
            guard ctx.hasChanges else { return }
            do {
                try ctx.save()
            } catch {
                lastError = error
            }
        }
    }
}

extension NSManagedObjectContext {
    func trySave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            AppLog().error("\(error)")
        }
    }
}

#if DEBUG
extension DBManager {
    func dump() {
        Task {
            var items: [NSManagedObject]!
            items = await AppDatabase().context.fetch(CDEngine.fetchRequest())
            print("Engine:")
            print((items as NSArray).description)

            items = await AppDatabase().context.fetch(CDConversation.fetchRequest())
            print("Conversation:")
            print((items as NSArray).description)
        }
    }
}
#endif
