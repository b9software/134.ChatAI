/*
 GeneralListDataSource.swift

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import HasItem
import UIKit

/**
 section is always 0.

 Example:

 ```
 lazy var listDataSource = GeneralSingleSectionListDataSource<Conversation>(tableView: listView, cellProvider: UITableView.cellProvider(_:indexPath:object:))

 @IBOutlet private weak var listView: UITableView! {
     didSet {
         listView.dataSource = listDataSource
     }
 }
 ```
 */
class GeneralSingleSectionListDataSource<Item: Hashable>:
    UITableViewDiffableDataSource<Int, Item>,
    UITableViewDelegate
{
    typealias ListItem = Item

    /// 设置为 true 选中状态追踪 item 自身的状态，
    /// 否则 selectedItems 追踪 table view 本身的选中
    var isItemSelectable = false

    /// 选中的对象
    var selectedItems: [Item] {
        get {
            if isItemSelectable {
                return inputItems.filter { ($0 as? ItemSelectable)?.isSelected == true }
            } else {
                return (tableView?.indexPathsForSelectedRows?.compactMap { itemIdentifier(for: $0) }) ?? []
            }
        }
        set {
            guard let tableView = tableView else { return }
            if isItemSelectable {
                fatalError("todo")
            } else {
                selectRows(items: newValue)
            }
        }
    }

    /// 选取变化
    var onSelectionChanged: ((GeneralSingleSectionListDataSource) -> Void)? {
        didSet {
            onSelectionChanged?(self)
        }
    }

    /// 搜索关键字，nil 重置，非 nil 搜索
    var searchKey: String? {
        didSet {
            updateSnapshot()
        }
    }

    /// 需要排除的对象，在 update(items:) 之前设置，不支持动态修改
    var excludeItems = [Item]()

    /// 绑定的状态 view，在空和正常状态切换
    var stateView: ListStateView?

    private(set) weak var tableView: UITableView?

    var cellConfig: ((UITableViewCell, ListItem, IndexPath) -> Void)?

    override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Int, Item>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
        self.tableView = tableView
    }

    // MARK: -

    func update(listItems: [ListItem]) {
        inputItems = listItems
        updateSnapshot()
        if let items = itemSelectedNeedsRestore {
            selectRows(items: items)
        }
    }

    func item(at indexPath: IndexPath) -> ListItem? {
        itemIdentifier(for: indexPath)
    }

    private(set) var inputItems = [ListItem]()
    private func updateSnapshot() {
        var displayItems = inputItems
        if let search = searchKey {
            displayItems = displayItems.filter {
                ($0 as? ItemTextSearchable)?.isSearchIncluded(in: search) == true
            }
        }
        var snap = NSDiffableDataSourceSnapshot<Int, Item>()
        snap.appendSections([0])
        snap.appendItems(displayItems, toSection: 0)
        apply(snap, animatingDifferences: tableView?.isVisible == true)
        updateStateView(isEmpty: displayItems.isEmpty)
    }

    private func updateStateView(isEmpty: Bool) {
        guard let sView = stateView else { return }
        if isEmpty {
            if let search = searchKey {
                sView.state = .empty("没有找到“\(search)”相关结果")
            } else {
                sView.state = .empty(nil)
            }
            return
        }
        sView.state = .normal
    }

    // MARK: - 选中处理

    private var itemSelectedNeedsRestore: [Item]?

    private func selectRows(items: [Item]?) {
        guard let tableView = tableView else { return }
        if items?.isNotEmpty == true, inputItems.isEmpty {
            itemSelectedNeedsRestore = items
            return
        }
        let newIndexPaths = items?.compactMap { indexPath(for: $0) }
        tableView.setSelected(indexPaths: newIndexPaths, animated: false)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = itemIdentifier(for: indexPath)!
        if isItemSelectable {
            if let selectableItem = item as? ItemSelectable {
                let shouldSelected = !selectableItem.isSelected
                if !tableView.allowsMultipleSelection {
                    if shouldSelected {
                        // 反选已有 cell
                        inputItems.forEach {
                            if let selectable = $0 as? ItemSelectable,
                               selectable.isSelected {
                                selectable.isSelected = false
                                updateCell(item: $0, tableView: tableView)
                            }
                        }
                    }
                }
                selectableItem.isSelected = shouldSelected
            }
        } else {
            // selection follow table view
        }
        updateCell(item: item, tableView: tableView)
        onSelectionChanged?(self)
    }

    // MARK: -

    private func updateCell(item: ListItem, tableView: UITableView) {
        guard let indexPath = indexPath(for: item),
              tableView.indexPathsForVisibleRows?.contains(indexPath) == true else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError()
        }
        if let config = cellConfig {
            config(cell, item, indexPath)
        } else if var cell = cell as? AnyHasItem {
            cell.setItem(item)
        }
        if let selectableCell = cell as? CellSelectable {
            let isSelected: Bool
            if isItemSelectable {
                isSelected = (item as? ItemSelectable)?.isSelected ?? false
            } else {
                isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
            }
            selectableCell.update(isSelected: isSelected)
        }
    }
}
