//
//  CDFetchTableViewDataSource.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData
import HasItem
import UIKit

/**

 ```
 private lazy var listDataSource = CDFetchTableViewDataSource<CDEntity>()
 @IBOutlet private weak var listView: UITableView!

 override func viewDidLoad() {
     super.viewDidLoad()
     listDataSource.tableView = listView
     listDataSource.fetchRequest = ...
 }
 ```
 */
class CDFetchTableViewDataSource<Entity: NSManagedObject>:
    UITableViewDiffableDataSource<Int, Entity>,
    NSFetchedResultsControllerDelegate
{
    weak var tableView: UITableView?

    init(tableView: UITableView) {
        self.tableView = tableView
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
    var selectedItems: [Entity]? {
        get {
            tableView?.indexPathsForSelectedRows?.compactMap { item(at: $0) }
        }
        set { selectRows(items: newValue) }
    }

    /// 数据刷新前后，通过追踪选中对象，保持列表选中的元素不变
    var keepsSelectionThroughIndexPaths = false
    private var itemSelectedNeedsRestore: [Entity]?

    // MARK: Access

    var listItems = [Entity]()

    func item(at indexPath: IndexPath?) -> Entity? {
        guard let ip = indexPath else { return nil }
        return listItems.element(at: ip.row)
    }

    func items(at indexPaths: [IndexPath]) -> [Entity] {
        indexPaths.compactMap {
            item(at: $0)
        }
    }

    func indexPath(of entity: Entity) -> IndexPath? {
        if let idx = listItems.firstIndex(of: entity) {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }

    var managedObjectContext: NSManagedObjectContext? {
        fetchController?.managedObjectContext
    }

    // MARK: -

    func updateSnapShot(listItems: [Entity]) {
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
        dispatch_async_on_main { [weak self] in
            self?.updateSnapShot(listItems: items)
        }
    }
}

extension CDFetchTableViewDataSource {
    var isDataLoaded: Bool {
        tableView?.indexPathsForVisibleRows?.isNotEmpty ?? false
    }

    private func selectRows(items: [Entity]?) {
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
