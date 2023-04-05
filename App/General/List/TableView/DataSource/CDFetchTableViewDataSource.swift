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
    NSObject,
    UITableViewDataSource,
    NSFetchedResultsControllerDelegate
{
    weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
        }
    }

    /// Set before set `fetchRequest`
    var fetchCacheName: String?

    var fetchRequest: NSFetchRequest<Entity>? {
        didSet {
            guard let request = fetchRequest else { return }
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Current.database.viewContext, sectionNameKeyPath: nil, cacheName: fetchCacheName)
        }
    }

    private(set) var fetchController: NSFetchedResultsController<Entity>? {
        didSet {
            fetchController?.delegate = self
            Do.try {
                try fetchController?.performFetch()
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

    func item(at indexPath: IndexPath?) -> Entity? {
        guard let ip = indexPath else { return nil }
        return fetchController?.object(at: ip)
    }

    func items(at indexPaths: [IndexPath]) -> [Entity] {
        indexPaths.compactMap {
            fetchController?.object(at: $0)
        }
    }

    func indexPath(of entity: Entity) -> IndexPath? {
        fetchController?.indexPath(forObject: entity)
    }

    var managedObjectContext: NSManagedObjectContext? {
        fetchController?.managedObjectContext
    }

    // MARK: -

    func numberOfSections(in tableView: UITableView) -> Int {
        fetchController?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchController?.sections?[section].numberOfObjects ?? 0
        emptyView?.isHidden = !(section == 0 && count == 0)
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? (UITableViewCell & AnyHasItem) else {
            fatalError("Cell must confirm to HasItem.")
        }
        let item = fetchController?.object(at: indexPath)
        cell.setItem(item)
        return cell
    }

    // MARK: -

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        trackSelectionBeginRefresh()
        tableView?.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
        emptyView?.isHidden = controller.fetchedObjects?.count != 0
        trackSelectionEndRefresh()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let table = tableView else { return }
        switch type {
        case .insert:
            table.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            table.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            table.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            table.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex idx: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: idx), with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: idx), with: .fade)
        default:
            break
        }
    }
}

extension CDFetchTableViewDataSource {
    var isDataLoaded: Bool {
        tableView?.indexPathsForVisibleRows?.isNotEmpty ?? false
    }

    private func selectRows(items: [Entity]?) {
        guard let tableView = tableView else { return }
        // @bug: indexPath(of: $0) 在未完全加载好时无返回
        let entities = fetchController?.fetchedObjects ?? []
        let newIndexPaths = items?.compactMap { entities.firstIndex(of: $0) }.map { IndexPath(row: $0, section: 0) }
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
