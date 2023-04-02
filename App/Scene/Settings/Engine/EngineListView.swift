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
        listDataSource.tableView = self
        listDataSource.fetchCacheName = "engine_list"
        delegate = self
        selectionFollowsFocus = true
        allowsFocus = true
        allowsMultipleSelection = true
    }

    private lazy var listDataSource = CDFetchTableViewDataSource<CDEngine>()

    var fetchRequest: NSFetchRequest<CDEngine>? {
        didSet {
            listDataSource.fetchRequest = fetchRequest
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

    private lazy var needsUpdateFocus = DelayAction(Action(target: self, selector: #selector(doUpdateFocus)))

    @objc
    private func doUpdateFocus() {
        hasSelection = indexPathsForSelectedRows?.isNotEmpty == true
    }

    override func delete(_ sender: Any?) {
        indexPathsForSelectedRows?.forEach { ip in
            listDataSource.item(at: ip)?.delete()
        }
    }

    @objc
    func deleteFromMenu(sender: UICommand) {
        guard let idx = sender.propertyList as? Int else {
            assert(false)
            return
        }
        let ip = IndexPath(row: idx, section: 0)
        guard let entity = listDataSource.item(at: ip) else {
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

/// 用于会话设置
class EnginePickListCell: GeneralListCell {

}

/// 用于管理
class EngineListCell: GeneralListCell {
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
