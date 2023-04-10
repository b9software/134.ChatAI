//
//  MessageDataSource.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import CoreData
import HasItem
import UIKit


class MessageDataSource:
    NSObject,
    UITableViewDataSource,
    NSFetchedResultsControllerDelegate
{

    weak var view: UITableView!
    var conversation: Conversation! {
        didSet {
            assert(oldValue == nil)
            refresh()
        }
    }

    init(tableView: UITableView) {
        super.init()
        view = tableView
        tableView.dataSource = self
    }

    // MARK: - Loading

    private func refresh() {
        Current.database.context.async { [weak self] ctx in
            guard let sf = self else { return }
            let fetch = NSFetchedResultsController(
                fetchRequest: CDMessage.conversationRequest(sf.conversation.entity, offset: 0, limit: sf.pageSize, ascending: false),
                managedObjectContext: ctx,
                sectionNameKeyPath: nil, cacheName: nil)
            fetch.delegate = self
            sf.fetchController = fetch
            try fetch.performFetch()
        }
    }

    #if DEBUG
    private let pageSize = 50
    #else
    private let pageSize = 999
    #endif
    private var historyReachEnd = false
    private var isLoading = true

    func loadHistory() {
        if historyReachEnd { return }
        if isLoading {
            AppLog().debug("DS> 正在加载，跳过 loadHistory()")
            return
        }
        let offset = listItems.count
        guard offset > 0 else {
            AppLog().info("DS> 未首次加载就调历史")
            return
        }
        isLoading = true
        Current.database.context.async { [weak self] ctx in
            guard let sf = self else { return }
            let req = CDMessage.conversationRequest(sf.conversation.entity, offset: offset, limit: sf.pageSize, ascending: true)
            let entities = try ctx.fetch(req)
            let items = entities.compactMap {
                do {
                    try $0.validate()
                    return Message.from(entity: $0)
                } catch {
                    return nil
                }
            }
            Task { @MainActor in
                sf.insertHistory(items: items)
            }
        }
    }

    func insertHistory(items: [Message]) {
        if items.count < pageSize {
            historyReachEnd = true
        }
        assertDispatch(.onQueue(.main))
        AppLog().debug("DS> insert \(items)")
        let ips = (0..<items.count).map { IndexPath(row: $0, section: 0) }

        let list = view as! MessageListView  // swiftlint:disable:this force_cast
//        list.beginKeepBottom(rule: false)

//        let visibleIndex: IndexPath = view.indexPathsForVisibleRows?.min() ?? IndexPath(row: 0, section: 0)
//        let offsetBefore = view.rectForRow(at: visibleIndex).minY

        listItems.insert(contentsOf: items, at: 0)
        heightCache.insert(contentsOf: [CGFloat?](repeating: nil, count: items.count), at: 0)
        AppLog().debug("DS> being insert")
        view.insertRows(at: ips, with: .none)
        AppLog().debug("DS> end insert")

//        list.endKeepBottom(rule: false)

//        let indexPathAfter = IndexPath(row: visibleIndex.row + items.count, section: 0)
//        let offsetAfter = view.rectForRow(at: indexPathAfter).minY
//        var offset = view.contentOffset
//        offset.y += offsetAfter - offsetBefore
//        view.contentOffset = offset
        dispatch_after_seconds(1) { [weak self] in
            self?.isLoading = false
        }
    }

    func applyFetched(items: [Message]) {
        assertDispatch(.onQueue(.main))
        AppLog().debug("DS> append \(items)")
        if listItems.isEmpty {
            listItems.append(contentsOf: items.reversed())
            heightCache.append(contentsOf: [CGFloat?](repeating: nil, count: items.count))
            view.reloadData()
            dispatch_after_seconds(0) { [weak self] in
                self?.view?.scrollToLastRow(animated: false)
            }
            return
        }
        if items.isEmpty {
            historyReachEnd = true
            return
        }
        var lastIdxNotInList: Int?
        for (idx, item) in items.enumerated() {
            if listItems.contains(where: { $0 === item }) {
                break
            }
            lastIdxNotInList = idx
        }
        guard let idx = lastIdxNotInList else {
            AppLog().debug("DS> all in list, skip")
            return
        }
        AppLog().debug("DS> insert 0...\(idx)")
        guard let view = view else {
            listItems.append(contentsOf: items[0...idx].reversed())
            heightCache.append(contentsOf: [CGFloat?](repeating: nil, count: idx + 1))
            return
        }

        let start = listItems.count
        listItems.append(contentsOf: items[0...idx].reversed())
        heightCache.append(contentsOf: [CGFloat?](repeating: nil, count: idx + 1))
        let ips = (0...idx).map { IndexPath(row: start + $0, section: 0) }
        view.performBatchUpdates({
            view.insertRows(at: ips, with: .fade)
        }, completion: {
            view.scrollToLastRow(animated: $0)
        })
    }

    // MARK: - Fetch

    private var fetchController: NSFetchedResultsController<CDMessage>?

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        assertDispatch(.notOnQueue(.main))
        // 插入直接会在结果里，而不会限制在最初的 fetch limit

        let ctx = Current.database.context.ctx
        let items: [Message] = snapshot.itemIdentifiers
            .compactMap {
                guard let id = $0 as? NSManagedObjectID,
                      let entity = ctx.object(with: id) as? CDMessage else {
                    assert(false)
                    return nil
                }
                do {
                    try entity.validate()
                    return Message.from(entity: entity)
                } catch {
                    return nil
                }
            }
        Task { @MainActor in
            applyFetched(items: items)
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AppLog().debug("DS> messages will change")
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AppLog().debug("DS> messages did change")
    }

    // MARK: - List

    var listItems = [Message]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listItems[indexPath.row]
        let cellID = item.cellIdentifier(for: tableView, indexPath: indexPath)
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageBaseCell else {
            fatalError()
        }
        cell.setItem(item.cellItem())
        if let sizeView = cell.sizeView,
           let height = cachedHeight(at: indexPath) {
            sizeView.heightConstraint.constant = height
        }
        return cell
    }

    // MARK: Cell Height

    private var heightCache = [CGFloat?]()

    func cachedHeight(at indexPath: IndexPath) -> CGFloat? {
        heightCache.element(at: indexPath.row) ?? nil
    }
    func updateHeight(_ height: CGFloat, for cell: UITableViewCell) {
        guard let ip = view.indexPath(for: cell) else {
            return
        }
        if heightCache[ip.row] == height { return }
        heightCache[ip.row] = height
//        indexPathsCellHeight.append(ip)
        needsUpdateCellHeight.set()
        AppLog().debug("DS> update height at \(ip.row) to \(height).")

    }
//    private var indexPathsCellHeight = [IndexPath]()
    private lazy var needsUpdateCellHeight = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.view.beginUpdates()
        sf.view.endUpdates()
//        sf.view.reloadRows(at: sf.indexPathsCellHeight, with: .none)
//        sf.indexPathsCellHeight = []
    })
}
