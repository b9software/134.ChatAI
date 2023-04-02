//
//  DBManager.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

/**
 注意：在远端修改后 UI 与内存中的状态同步

 Guide:
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html
 https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/creating_a_core_data_model_for_cloudkit
 */
class DBManager {
    typealias CDContainer = NSPersistentCloudKitContainer

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
        let description: NSPersistentStoreDescription
        if test {
            description = .init()
            description.type = NSInMemoryStoreType
        } else {
            description = .init(url: FileURL.database)
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
        container.viewContext.automaticallyMergesChangesFromParent = true
        let instance = DBManager(container: container)
        loadedModel = container.managedObjectModel
        return instance
    }

    let container: CDContainer
    let context: CDContext

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(container: CDContainer) {
        self.container = container
        self.context = CDContext(ctx: container.newBackgroundContext())
    }
}

class CDContext {
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
        assertDispatch(.notOnQueue(.main))
        return ctx.performAndWait {
            do {
                return try ctx.fetch(request)
            } catch {
                lastError = error
                return nil
            }
        }
    }

    func save() {
        assertDispatch(.notOnQueue(.main))
        ctx.performAndWait {
            guard ctx.hasChanges else { return }
            do {
                try ctx.save()
            } catch {
                lastError = error
            }
        }
    }

    func perform<T>(save: Bool = true, _ operation: (NSManagedObjectContext) throws -> T) rethrows -> T {
        assertDispatch(.notOnQueue(.main))
        let result = try ctx.performAndWait {
            try operation(ctx)
        }
        if save {
            self.save()
        }
        return result
    }
}

extension NSManagedObjectContext {
    func trySave() {
        guard hasChanges else { return }
        Do.try {
            try save()
        }
    }
}

protocol CDEntityAccessing {
    var managedObjectContext: NSManagedObjectContext? { get }
}
extension CDEntityAccessing {
    /// For safely accessing the properties of an NSManagedObject object.
    ///
    /// CoreData objects are not thread-safe.
    /// This method perform the given block on the object context queue.
    ///
    /// You can write like that:
    /// ```
    /// let title = entity.access { $0.title }
    /// ```
    func access<T>(_ block: (Self) -> T) -> T {
        guard let ctx = managedObjectContext else {
            fatalError("\(self) must create with object context")
        }
        var result: T!
        ctx.performAndWait {
            result = block(self)
        }
        return result
    }

    /// Make asynchronous changes then save safely
    func modify(_ block: @escaping (Self, NSManagedObjectContext) -> Void) {
        guard let ctx = managedObjectContext else {
            fatalError("\(self) must create with object context")
        }
        ctx.perform {
            block(self, ctx)
            ctx.trySave()
        }
    }
}
extension NSManagedObject: CDEntityAccessing {}

#if DEBUG
extension DBManager {
    func dump() {
        Do.try {
            let context = Current.database.viewContext

            var items: [NSManagedObject]!
            items = try context.fetch(CDEngine.fetchRequest())
            print("Engine:")
            print((items as NSArray).description)

            items = try context.fetch(CDConversation.debugRequest)
            print("Conversation:")
            print((items as NSArray).description)
        }
    }
}
#endif
