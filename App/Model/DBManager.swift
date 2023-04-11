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
    let backgroundContext: NSManagedObjectContext

    private(set) var lastError: Error? {
        didSet {
            if let err = lastError {
                AppLog().error("DB> Error: \(err)")
            }
        }
    }

    init(container: CDContainer) {
        self.container = container
        backgroundContext = container.newBackgroundContext()
    }

    /// Async read in background
    func read<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { checked in
            let ctx = backgroundContext
            ctx.perform {
                do {
                    checked.resume(returning: try block(ctx))
                } catch {
                    checked.resume(throwing: error)
                }
            }
        }
    }

    /// Async read in background
    func read<T>(_ block: @escaping (NSManagedObjectContext) -> T) async -> T {
        await withCheckedContinuation { checked in
            let ctx = backgroundContext
            ctx.perform {
                checked.resume(returning: block(ctx))
            }
        }
    }

    /// Async make change then save in background
    func write<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
        let ctx = backgroundContext
        return try await ctx.perform(schedule: .enqueued, {
            try block(ctx)
        })
    }

    /// Async read
    func async(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        let ctx = backgroundContext
        ctx.perform {
            Do.try {
                try block(ctx)
            }
        }
    }

    /// Async save
    func save(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        let ctx = backgroundContext
        ctx.perform {
            Do.try {
                try block(ctx)
                try ctx.save()
            }
        }
    }
}

private extension NSManagedObjectContext {
    func trySave() {
        assertDispatch(.notOnQueue(.main))
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

    func read<T>(_ block: (Self, NSManagedObjectContext) throws -> T) -> T? {
        guard let ctx = managedObjectContext else {
            fatalError("\(self) must create with object context")
        }
        return ctx.performAndWait {
            do {
                return try block(self, ctx)
            } catch {
                AppLog().critical("DB> Read error: \(error).")
                return nil
            }
        }
    }

    /// Async read
    func async(_ block: @escaping (Self, NSManagedObjectContext) -> Void) {
        guard let ctx = managedObjectContext else {
            fatalError("\(self) must create with object context")
        }
        ctx.perform {
            block(self, ctx)
        }
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
            let context = Current.database.backgroundContext

            var items: [NSManagedObject]!
            items = try context.fetch(CDEngine.fetchRequest())
            print("Engine:")
            print((items as NSArray).description)

            items = try context.fetch(CDConversation.debugRequest)
            print("Conversation:")
            print((items as NSArray).description)

            items = try context.fetch(CDMessage.fetchRequest())
            print("Message:")
            print((items as NSArray).description)
        }
    }
}
#endif
