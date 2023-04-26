/*
 应用级别的便捷方法
 */
extension UITableView {

    // @MBDependency:2
    /// 选中某一 section 的全部 cell
    func selectRows(ofSection section: Int, animated: Bool) {
        for i in 0..<numberOfRows(inSection: section) {
            selectRow(at: IndexPath(row: i, section: section), animated: animated, scrollPosition: .none)
        }
    }

    func selectRow(at indexPath: IndexPath, animated: Bool, scrollToVisible: Bool) {
        selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        if scrollToVisible {
            let frame = rectForRow(at: indexPath)
            scrollRectToVisible(frame, animated: animated)
        }
    }

    // @MBDependency:2
    /// 反选某一 section 的全部 cell
    func deselectRows(ofSection section: Int, animated: Bool) {
        for i in 0..<numberOfRows(inSection: section) {
            deselectRow(at: IndexPath(row: i, section: section), animated: animated)
        }
    }

    /// Update list selection with new indexPaths
    func setSelected(indexPaths: [IndexPath]?, animated: Bool) {
        let oldIndexPaths = indexPathsForSelectedRows ?? []
        let newIndexPaths = indexPaths ?? []
        if oldIndexPaths == newIndexPaths { return }
        oldIndexPaths.forEach {
            deselectRow(at: $0, animated: animated)
        }
        newIndexPaths.forEach {
            selectRow(at: $0, animated: animated, scrollPosition: .none)
        }
    }

    // @MBDependency:1
    /// 某一 section 的选中单元数量
    func selectRowCount(inSection section: Int) -> Int {
        guard let ips = indexPathsForSelectedRows else {
            return 0
        }
        var count = 0
        for ip in ips where ip.section == section {
            count += 1
        }
        return count
    }

    // @MBDependency:2
    /// 可见 cell 的 IndexPath 集合
    var indexPathsForVisibleCells: [IndexPath] {
        visibleCells.compactMap { indexPath(for: $0) }
    }

    /// 最后一行的 IndexPath
    var lastRowIndexPath: IndexPath? {
        let section = numberOfSections - 1
        guard section >= 0 else { return nil }
        let row = numberOfRows(inSection: section) - 1
        guard row >= 0 else { return nil }
        return IndexPath(row: row, section: section)
    }

    /// 滚动到最后一行
    func scrollToLastRow(animated: Bool) {
        guard let ip = lastRowIndexPath else { return }
        scrollToRow(at: ip, at: .middle, animated: animated)
    }
}

/// 防止 cell 高亮时变色
class TableCellBackground: UIView {
    var color: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    override var backgroundColor: UIColor? {
        get {
            color
        }
        set {
            if color != nil { return }
            color = newValue
        }
    }
    override func draw(_ rect: CGRect) {
        color?.setFill()
        UIRectFill(rect)
    }
}
