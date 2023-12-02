//
//  CDFetchTableViewDataSource.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppFramework
import CoreData
import UIKit

/**

 ```
 private lazy var listDataSource = CDFetchTableViewDataSource<Item, CDEntity>(tableView: listView, transformer: ...)
 @IBOutlet private weak var listView: UITableView!

 override func viewDidLoad() {
     super.viewDidLoad()
     listDataSource.fetchRequest = ...
 }
 ```
 */
class CDFetchTableViewDataSource<ListEntity: Hashable, Entity: NSManagedObject>:
    UITableViewDiffableDataSource<Int, ListEntity>,
    NSFetchedResultsControllerDelegate
{
    weak var tableView: UITableView?
    let listEntityTransformer: (Entity) -> ListEntity?

    init(tableView: UITableView, transformer: @escaping (Entity) -> ListEntity?) {
        self.tableView = tableView
        listEntityTransformer = transformer
        super.init(tableView: tableView, cellProvider: UITableView.cellProvider(_:indexPath:object:))
        tableView.dataSource = self
    }

    /// Set before set `fetchRequest`
    var fetchCacheName: String?

    var fetchRequest: NSFetchRequest<Entity>? {
        didSet {
            guard let request = fetchRequest else { return }
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Current.database.backgroundContext, sectionNameKeyPath: nil, cacheName: fetchCacheName)
        }
    }

    private(set) var fetchController: NSFetchedResultsController<Entity>? {
        didSet {
            fetchController?.delegate = self
            Current.database.async { [weak self] _ in
                try self?.fetchController?.performFetch()
            }
        }
    }

    weak var emptyView: UIView?

    /// 选中的对象
    var selectedItems: [ListEntity]? {
        get {
            tableView?.indexPathsForSelectedRows?.compactMap { item(at: $0) }
        }
        set { selectRows(items: newValue) }
    }

    /// 数据刷新前后，通过追踪选中对象，保持列表选中的元素不变
    var keepsSelectionThroughIndexPaths = false
    private var itemSelectedNeedsRestore: [ListEntity]?

    // MARK: Access

    var listItems = [ListEntity]()

    func item(at indexPath: IndexPath?) -> ListEntity? {
        guard let ip = indexPath else { return nil }
        return listItems.element(at: ip.row)
    }

    func items(at indexPaths: [IndexPath]) -> [ListEntity] {
        indexPaths.compactMap {
            item(at: $0)
        }
    }

    func indexPath(of entity: ListEntity) -> IndexPath? {
        if let idx = listItems.firstIndex(of: entity) {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }

    var managedObjectContext: NSManagedObjectContext? {
        fetchController?.managedObjectContext
    }

    // MARK: -

    func updateSnapShot(listItems: [ListEntity]) {
        trackSelectionBeginRefresh()
        self.listItems = listItems
        var snap = snapshot()
        snap.deleteAllItems()
        snap.appendSections([0])
        snap.appendItems(listItems, toSection: 0)
        apply(snap) {
            self.trackSelectionEndRefresh()
        }
        emptyView?.isHidden = listItems.count != 0
    }

    // MARK: -

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let ids = snapshot.itemIdentifiers as? [NSManagedObjectID] else {
            assert(false)
            return
        }
        let entities = ids.map { controller.managedObjectContext.object(with: $0) }
        guard let items = entities as? [Entity] else {
            assert(false)
            return
        }
        let listItems = items.compactMap(listEntityTransformer)
        Task { @MainActor in
            updateSnapShot(listItems: listItems)
        }
    }
}

extension CDFetchTableViewDataSource {
    var isDataLoaded: Bool {
        tableView?.indexPathsForVisibleRows?.isNotEmpty ?? false
    }

    private func selectRows(items: [ListEntity]?) {
        guard let tableView = tableView else { return }
        if items?.isNotEmpty == true, listItems.isEmpty {
            itemSelectedNeedsRestore = items
            return
        }
        let newIndexPaths = items?.compactMap { indexPath(for: $0) }
        tableView.setSelected(indexPaths: newIndexPaths, animated: false)
    }

    private func trackSelectionBeginRefresh() {
        guard keepsSelectionThroughIndexPaths,
              itemSelectedNeedsRestore == nil else {
            return
        }
        if let indexPaths = tableView?.indexPathsForSelectedRows {
            itemSelectedNeedsRestore = items(at: indexPaths)
        }
    }

    private func trackSelectionEndRefresh() {
        if !keepsSelectionThroughIndexPaths { return }
        if let items = itemSelectedNeedsRestore {
            items
                .compactMap { indexPath(of: $0) }
                .forEach {
                    tableView?.selectRow(at: $0, animated: false, scrollPosition: .none)
                }
            itemSelectedNeedsRestore = nil
        }
    }
}
