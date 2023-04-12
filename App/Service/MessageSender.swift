//
//  MessageSender.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData

struct SenderState: Equatable {
    var isSending: Bool
    var error: Error?

    static func == (lhs: SenderState, rhs: SenderState) -> Bool {
        lhs.isSending == rhs.isSending
        && lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}

actor MessageSender:
    NSObject,
    NSFetchedResultsControllerDelegate
{
    private var fetchControl: NSFetchedResultsController<CDMessage>!
    private let queue = OperationQueue()

    @MainActor func startIfNeeded() {
        Task {
            await setupFetch()
        }
    }

    func stop(message: Message) {
        removeItem(message)
    }

    override init() {
        super.init()
        queue.name = "app.MessageSender"
        queue.maxConcurrentOperationCount = 2
        queue.qualityOfService = .utility
    }

    private func setupFetch() {
        guard fetchControl == nil else { return }
        Do.try {
            let request = CDMessage.pendingRequest()
            let control = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: Current.database.backgroundContext,
                sectionNameKeyPath: nil,
                cacheName: "message_pending")
            control.delegate = self
            try control.performFetch()
            fetchControl = control
            AppLog().info("MD> Did setup fetcher.")
            loadInitItems()
        }
    }

    private func loadInitItems() {
        Current.database.save { [self] _ in
            for entity in fetchControl.fetchedObjects ?? [] {
                assert(entity.mState == .pend)
                if Date.isRecent(entity.time, range: 60) {
                    addItem(.from(entity: entity))
                } else {
                    entity.mState = .froze
                }
            }
            logDebugDescription()
        }
    }

    private var works = [MessageOperation]()

    private func addItem(_ item: Message) {
        AppLog().info("MS> Add item \(item)")
        let operation = MessageOperation(message: item)
        works.append(operation)
        operation.completionBlock = { [weak self] in
            guard let sf = self else { return }
            Task {
                await sf.onCompletion(operation)
            }
        }
        queue.addOperation(operation)
    }

    private func onCompletion(_ operation: MessageOperation) {
        if let idx = works.firstIndex(of: operation) {
            works.remove(at: idx)
        }
    }

    private func removeItem(_ item: Message) {
        AppLog().info("MS> Remove item \(item)")
        for work in works where work.message == item {
            work.cancel()
        }
    }

    nonisolated func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let entity = anObject as? CDMessage else {
            fatalError()
        }
        switch type {
        case .insert, .delete:
            let item = Message.from(entity: entity)
            Task {
                if type == .insert {
                    await addItem(item)
                } else {
                    await removeItem(item)
                }
            }
        default:
            break
        }
    }

    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AppLog().debug("MS> Fetch did change.")
    }

    func logDebugDescription() {
        let items = works.map { $0.message }
        let desc = "MessageSender:\n"
        + "working: \(items)"
        AppLog().debug("\(desc)")
    }
}

// MARK: - Engine work

class MessageOperation: Operation {
    let message: Message
    var engineTask: Task<Void, Error>?

    init(message: Message) {
        self.message = message
        super.init()
    }

    override func main() {
        AppLog().warning("Task start")
        super.main()
        message.senderState = SenderState(isSending: true)

        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                try await asyncRun()
                try await engineTask?.value
                message.senderState = nil
                AppLog().debug("Task async finished")
            } catch {
                message.senderState = SenderState(isSending: false, error: error)
                if AppError.isCancel(error) {
                    AppLog().info("Task cancelled.")
                } else {
                    AppLog().error("Task error: \(error)")
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
        AppLog().warning("Task finished")
    }

    func asyncRun() async throws {
        try checkCancel()
        let conversation = try await message.loadConversation()
        let engine = try await conversation.loadEngine()
        let config = conversation.engineConfig
        try checkCancel()
        engineTask = try engine.send(message: message, config: config)
    }

    func checkCancel() throws {
        if isCancelled { throw AppError.cancel }
    }

    override func cancel() {
        super.cancel()
        engineTask?.cancel()
    }
}
