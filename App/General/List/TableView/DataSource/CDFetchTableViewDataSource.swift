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

    // MARK: Access

    func item(at indexPath: IndexPath?) -> Entity? {
        guard let ip = indexPath else { return nil }
        return fetchController?.object(at: ip)
    }

    var managedObjectContext: NSManagedObjectContext? {
        fetchController?.managedObjectContext
    }

    // MARK: -

    func numberOfSections(in tableView: UITableView) -> Int {
        fetchController?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchController?.sections?[section].numberOfObjects ?? 0
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
        tableView?.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView?.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView?.moveRow(at: indexPath!, to: newIndexPath!)
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
