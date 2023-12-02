/*
 ListGeneral.swift

 Copyright © 2021, 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import Foundation

/// 一般列表对象
protocol ListItem {
    /// 通过 item 提供 cell 的重用标识符，默认 "Cell"
    func cellIdentifier(for: UITableView, indexPath: IndexPath) -> String
    func cellIdentifier(for: UICollectionView, indexPath: IndexPath) -> String
    /// 传给 cell item 的对象，默认是自身
    func cellItem() -> Any
}
extension ListItem {
    func cellIdentifier(for: UITableView, indexPath: IndexPath) -> String { "Cell" }
    func cellIdentifier(for: UICollectionView, indexPath: IndexPath) -> String { "Cell" }
    func cellItem() -> Any { self }
}

protocol ItemSortable {
    associatedtype TypeComparable: Comparable
    var valueForSort: TypeComparable { get }
}

protocol ItemSelectable: AnyObject {
    var isSelected: Bool { get set }
}

protocol ItemHasTitle {
    var title: String { get }
}

protocol ItemTextSearchable {
    func isSearchIncluded(in key: String) -> Bool
}

protocol CellSelectable {
    func update(isSelected: Bool)
}

/**
 使用 cell view 展示 item 的通用 cell 类型
 */
class GeneralListCell: UITableViewCell, HasItem {
    var item: Any! {
        didSet {
            if var cell = cellView as? AnyHasItem {
                cell.setItem(item)
            }
        }
    }

    @IBOutlet private weak var cellView: UIView?
    @IBOutlet private weak var selectedIndicatorImageView: UIImageView?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedIndicatorImageView?.isHighlighted = selected
    }
}

class GeneralSelectionListCell: UITableViewCell, HasItem {
    var item: ItemHasTitle! {
        didSet {
            titleLabel.text = item.title
            if let selectableItem = item as? ItemSelectable {
                selectionIndicator.isHighlighted = selectableItem.isSelected
                isItemSelectable = true
            } else {
                isItemSelectable = false
            }
        }
    }

    private var isItemSelectable = false

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectionIndicator: UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !isItemSelectable {
            selectionIndicator.isHighlighted = selected
        }
    }
}

class GeneralGridCell: UICollectionViewCell, HasItem {
    var item: Any! {
        didSet {
            var cell = cellView as? AnyHasItem
            cell?.setItem(item)
        }
    }

    @IBOutlet private(set) weak var cellView: UIView?
}

extension UITableView {
    /// 适用于通常的对象，使用 HasItem 设置 cell 的 item
    static func cellProvider(_ table: UITableView, indexPath: IndexPath, object: Any) -> UITableViewCell {
        guard var cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? (UITableViewCell & AnyHasItem) else {
            fatalError()
        }
        cell.setItem(object)
        return cell
    }

    /// 适用于 ListItem 包装对象，通过 HasItem 把 cellItem 设置到 cell 上
    static func cellProvider(_ table: UITableView, indexPath: IndexPath, item: ListItem) -> UITableViewCell {
        let cellID = item.cellIdentifier(for: table, indexPath: indexPath)
        guard var cell = table.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? (UITableViewCell & AnyHasItem) else {
            fatalError()
        }
        cell.setItem(item.cellItem())
        return cell
    }
}

extension UICollectionView {
    /// 适用于通常的对象，使用 HasItem 设置 cell 的 item
    static func cellProvider(_ collectionView: UICollectionView, indexPath: IndexPath, object: Any) -> UICollectionViewCell {
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? (UICollectionViewCell & AnyHasItem) else {
            fatalError()
        }
        cell.setItem(object)
        return cell
    }

    /// 适用于 ListItem 包装对象，通过 HasItem 把 cellItem 设置到 cell 上
    static func cellProvider(_ collectionView: UICollectionView, indexPath: IndexPath, item: ListItem) -> UICollectionViewCell {
        let cellID = item.cellIdentifier(for: collectionView, indexPath: indexPath)
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? (UICollectionViewCell & AnyHasItem) else {
            fatalError()
        }
        cell.setItem(item.cellItem())
        return cell
    }
}
