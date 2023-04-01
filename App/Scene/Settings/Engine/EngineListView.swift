//
//  EngineListView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import CoreData
import HasItem
import UIKit

class EngineListView: UITableView, UITableViewDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        selectionFollowsFocus = true
        allowsFocus = true
        allowsMultipleSelection = true
        allowsMultipleSelectionDuringEditing = true
    }

    var fetchRequest: NSFetchRequest<CDEngine>? {
        didSet {
            guard let request = fetchRequest else { return }
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDatabase().container.viewContext, sectionNameKeyPath: nil, cacheName: "engine_list")
        }
    }

    private(set) var fetchController: NSFetchedResultsController<CDEngine>? {
        didSet {
            fetchController?.delegate = self
            Do.try {
                try fetchController?.performFetch()
            }
        }
    }

    // MARK: -

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        needsUpdateFocus.set()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        needsUpdateFocus.set()
    }

    var hasSelection = false {
        didSet {
            if hasSelection {
                if UIResponder.firstResponder == nil {
                    _ = becomeFirstResponder()
                }
            } else {
                if isFirstResponder {
                    _ = resignFirstResponder()
                }
            }
        }
    }

    lazy var needsUpdateFocus = DelayAction(Action(target: self, selector: #selector(doUpdateFocus)))

    @objc
    private func doUpdateFocus() {
        hasSelection = indexPathsForSelectedRows?.isNotEmpty == true
    }

    override func delete(_ sender: Any?) {
        indexPathsForSelectedRows?.forEach { ip in
            guard let entity = fetchController?.object(at: ip) else {
                return
            }
            entity.managedObjectContext?.delete(entity)
        }
        fetchController?.managedObjectContext.trySave()
    }

    @objc
    func deleteFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int else {
            assert(false)
            return
        }
        guard let entity = fetchController?.object(at: IndexPath(row: idx, section: 0)) else {
            return
        }
        entity.managedObjectContext?.delete(entity)
    }

    override func selectAll(_ sender: Any?) {
        selectRows(ofSection: 0, animated: true)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            let deleteCommand = UICommand(
                title: L.Menu.delete,
                action: #selector(self.deleteFromMenu(sender:)),
                propertyList: indexPath.row)
            return UIMenu(children: [deleteCommand])
        })
    }

    // MARK: - Responder

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []
        commands.append(
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(delete))
        )
        return commands
    }
}

class EngineListCell: UITableViewCell, HasItem {
    var item: CDEngine! {
        didSet {
            cellView.item = item
        }
    }

    @IBOutlet private weak var cellView: EngineCellView!
    @IBOutlet private weak var boxView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBoxStyle()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBoxStyle()
    }

    private func updateBoxStyle() {
        if isHighlighted {
            boxView.backgroundColor = .tintColor
            boxView.layer.borderWidth = 0
        } else if isSelected {
            boxView.backgroundColor = .tintColor.withAlphaComponent(0.2)
            boxView.layer.borderColor = UIColor.tintColor.cgColor
            boxView.layer.borderWidth = 2
        } else {
            boxView.backgroundColor = .systemFill
            boxView.layer.borderWidth = 0
        }
    }
}

extension EngineListView: UITableViewDataSource {
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
}

extension EngineListView: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            deleteRows(at: [indexPath!], with: .fade)
        case .update:
            reloadRows(at: [indexPath!], with: .fade)
        case .move:
            moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex idx: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertSections(IndexSet(integer: idx), with: .fade)
        case .delete:
            deleteSections(IndexSet(integer: idx), with: .fade)
        default:
            break
        }
    }
}
