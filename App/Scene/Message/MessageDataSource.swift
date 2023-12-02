//
//  MessageDataSource.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppFramework
import B9Action
import CoreData
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

    /// 列表中的某一对象可能被移除，通知 vc 更新
    var itemMayRemove: ((MessageDataSource) -> Void)?

    // MARK: - Loading

    private func refresh() {
        Current.database.async { [weak self] ctx in
            guard let sf = self else { return }

            let fetch = NSFetchedResultsController(
                fetchRequest: CDMessage.conversationRequest(sf.conversation.entity, offset: 0, limit: sf.pageSize, ascending: false),
                managedObjectContext: ctx,
                sectionNameKeyPath: CDMessage.timeKey, cacheName: nil)
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
        Current.database.async { [weak self] ctx in
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

    // MARK: -

    var shouldUpdateSelectionForNewMessageInContext = false

    func insertHistory(items: [Message]) {
        /*
        if items.count < pageSize {
            historyReachEnd = true
        }
        assertDispatch(.onQueue(.main))
        AppLog().debug("DS> insert \(items)")
        let ips = (0..<items.count).map { IndexPath(row: $0, section: 0) }

        let list = view as! MessageListView  // swift lint:disable:this force_cast
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
         */
    }

    private var fetchController: NSFetchedResultsController<CDMessage>?

    private var listItems = [[Message]]()
    private var heightCache = [[CGFloat?]]()
    private lazy var needsUpdateCellHeight = DelayAction(Action { [weak self] in
        guard let sf = self else { return }
        sf.view.beginUpdates()
        sf.view.endUpdates()
    })
}

// MARK: - Update Logic

extension MessageDataSource {
    func applyFetched(items: [[Message]]) {
        if listItems == items { return }
        if listItems.isEmpty || items.isEmpty {
            resetList(items: items)
            return
        }
        AppLog().debug("DS> Start partial refresh.")
        if listItems.count != items.count {
            guard let newLastSection = items.last else { fatalError() }
            if listItems.last != newLastSection {
                AppLog().debug("DS> Append new context.")
                listItems.append(newLastSection)
                heightCache.append([CGFloat?](repeating: nil, count: newLastSection.count))
                view?.insertSections(IndexSet(integer: listItems.count - 1), with: .fade)
                dispatch_after_seconds(0) { [weak self] in
                    self?.view?.scrollToLastRow(animated: false)
                }
            } else {
                resetList(items: items)
            }
            return
        } else {
            for ((section, oldSection), newSection) in zip(listItems.enumerated(), items).reversed() {
                if oldSection == newSection { continue }
                applySectionChange(section: section, oldItems: oldSection, newItems: newSection)
                return
            }
            AppLog().debug("DS> Update? Ignore")
        }
    }

    private func applySectionChange(section: Int, oldItems: [Message], newItems: [Message]) {
        AppLog().debug("DS> Apply Section\(section) Change")
        listItems[section] = newItems
        heightCache[section] = [CGFloat?](repeating: nil, count: newItems.count)
        view.reloadSections(IndexSet(integer: section), with: .fade)
        if shouldUpdateSelectionForNewMessageInContext {
            shouldUpdateSelectionForNewMessageInContext = false
            if newItems.isEmpty { return }
            let ip = IndexPath(row: newItems.count - 1, section: section)
            view.selectRow(at: ip, animated: true, scrollPosition: .middle)
            view.next(type: UITableViewDelegate.self)?.tableView?(view, didSelectRowAt: ip)
        }
    }

    private func resetList(items: [[Message]]) {
        AppLog().debug("DS> Reset list.")
        if items.isEmpty {
            historyReachEnd = true
            if listItems.isNotEmpty {
                let count = listItems.count
                listItems = []
                heightCache = []
                view?.deleteSections(IndexSet(0..<count), with: .fade)
                itemMayRemove?(self)
            }
            return
        }
        listItems = items
        heightCache = items.map { sectionItems in
            [CGFloat?](repeating: nil, count: sectionItems.count)
        }
        view?.reloadData()
        itemMayRemove?(self)
        dispatch_after_seconds(0) { [weak self] in
            self?.view?.scrollToLastRow(animated: false)
        }
    }

    func deleteFromCell(_ cell: MessageBaseCell) {
        guard let indexPath = view?.indexPath(for: cell) else { return }
        let isSelected = cell.isSelected
        let isSectionRemoved = deleteItem(at: indexPath)
        if isSectionRemoved {
            view.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            view.deleteRows(at: [indexPath], with: .automatic)
            if indexPath.row == 0 {
                view.reloadRows(at: [indexPath], with: .fade)
            }
        }
        itemMayRemove?(self)

        // Update selection
        guard isSelected else { return }
        var nextSelectIP = indexPath
        if isSectionRemoved {
            nextSelectIP.row = 0
        }
        if let _ = item(at: nextSelectIP) {
            view.selectRow(at: nextSelectIP, animated: true, scrollToVisible: true)
            return
        }
        nextSelectIP.row = indexPath.row - 1
        if let _ = item(at: nextSelectIP) {
            view.selectRow(at: nextSelectIP, animated: true, scrollToVisible: true)
            return
        }
    }

    func scrollTo(item: Message?, selection: Bool, animated: Bool) {
        guard let item = item,
              let ip = indexPath(of: item) else {
            return
        }
        if selection {
            view.selectRow(at: ip, animated: animated, scrollPosition: .middle)
        } else {
            view.scrollToRow(at: ip, at: .middle, animated: animated)
        }
    }
}

// MARK: - List

extension MessageDataSource {
    var selectedItems: [Message] {
        guard let ips = view.indexPathsForSelectedRows else {
            return []
        }
        return ips.compactMap(item(at:))
    }

    func item(at ip: IndexPath) -> Message? {
        listItems.element(at: ip.section)?.element(at: ip.row)
    }

    func indexPath(of item: Message) -> IndexPath? {
        for (section, sectionItems) in listItems.enumerated().reversed() {
            guard let sectionFirstItem = sectionItems.first else { continue }
            if abs(sectionFirstItem.time.timeIntervalSince(item.time)) < 0.01 {
                for (row, listItem) in sectionItems.enumerated()
                where listItem == item {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }

    /// return: is section removed
    private func deleteItem(at indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        var sectionItems = listItems[section]
        sectionItems.remove(at: indexPath.row)
        let isSectionRemoved = sectionItems.isEmpty
        if isSectionRemoved {
            listItems.remove(at: section)
            heightCache.remove(at: section)
        } else {
            listItems[section] = sectionItems
            var heightItems = heightCache[section]
            heightItems.remove(at: indexPath.row)
            heightCache[section] = heightItems
        }
        return isSectionRemoved
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        listItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = item(at: indexPath) else {
            AppLog().critical("DS> Index out bounds!")
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
        let cellID = item.cellIdentifier(for: tableView, indexPath: indexPath)
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageBaseCell else {
            fatalError()
        }
        cell.indexPath = indexPath
        cell.setItem(item.cellItem())
        if let sizeView = cell.sizeView,
           let height = cachedHeight(at: indexPath) {
            sizeView.heightConstraint.constant = height
        }
        return cell
    }

    // MARK: Cell Height

    func cachedHeight(at indexPath: IndexPath) -> CGFloat? {
        guard let value = heightCache.element(at: indexPath.section)?.element(at: indexPath.row) else {
            return nil
        }
        return value
    }
    private func setCachedHeight(indexPath: IndexPath, value: CGFloat?) {
        var sectionItems = heightCache.element(at: indexPath.section) ?? {
            heightCache.insert([], at: indexPath.section)
            return []
        }()
        sectionItems[indexPath.row] = value
        heightCache[indexPath.section] = sectionItems
    }

    func updateHeight(_ height: CGFloat, for cell: UITableViewCell) {
        guard let ip = view.indexPath(for: cell) else {
            return
        }
        if cachedHeight(at: ip) == height { return }
        setCachedHeight(indexPath: ip, value: height)
        needsUpdateCellHeight.set()
    }
}

// MARK: - Fetch

extension MessageDataSource {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        assertDispatch(.notOnQueue(.main))
        // 插入直接会在结果里，而不会限制在最初的 fetch limit

        let ctx = controller.managedObjectContext
        let result = snapshot.sectionIdentifiers.reversed().map { section -> [Message] in
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section)
                .compactMap {
                    listItemFromSnap(identifier: $0, context: ctx)
                }
            return items.reversed()
        }
        dispatch_async_on_main { [weak self] in
            self?.applyFetched(items: result)
        }
    }

    func listItemFromSnap(identifier: Any, context: NSManagedObjectContext) -> Message? {
        guard let id = identifier as? NSManagedObjectID,
              let entity = context.object(with: id) as? CDMessage else {
            assert(false)
            return nil
        }
        do {
            try entity.validate()
            return Message.from(entity: entity)
        } catch {
            AppLog().warning("DS> Ignore item: \(error).")
            return nil
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AppLog().debug("DS> messages will change")
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        AppLog().debug("DS> messages did change")
    }
}
