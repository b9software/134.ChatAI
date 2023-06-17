//
//  MessageListView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import B9Action
import UIKit


class MessageListView: UITableView {
    /*
    var debugText: String {
        String(format: "ox%5.1f, ct%5.1f, %@", contentOffset.y, contentSize.height, bounds.size.debugDescription)
    }

    override var contentOffset: CGPoint {
        get { super.contentOffset }
        set {
            if isKeepBottom { return }
            super.contentOffset = newValue
        }
    }

    override var bounds: CGRect {
        didSet {
            if contentSize.height > bounds.height {
//                let diff = oldValue.height - bounds.height
//                guard diff > 0 else { return }
//                var offset = contentOffset
//                offset.y += diff
//                contentOffset = offset
            }
        }
    }

    override var contentSize: CGSize {
        willSet {
            if newValue == contentSize { return }
            AppLog().debug("\(debugText) <= begin contentSize will => \(newValue.height)")
            beginKeepBottom(newContentSize: newValue)
        }
        didSet {
            if oldValue == contentSize { return }
            endKeepBottom()
            AppLog().debug("\(debugText) <= end keep")
        }
    }

    private var offsetChange: CGFloat? {
        didSet {
            AppLog().debug("toBottomTrack = \(offsetChange?.description ?? "nil")")
        }
    }

    var isKeepBottom = false
    func beginKeepBottom(newContentSize: CGSize) {
        if newContentSize.height < bounds.height {
            return
        }
        if offsetChange != nil {
            AppLog().warning("begin but already in keep bottom")
            return
        }
        offsetChange = newContentSize.height - bounds.maxY
        isKeepBottom = true
    }

    func endKeepBottom() {
        defer { isKeepBottom = false }
        if contentSize.height < bounds.height {
            return
        }

        guard let diff = offsetChange else {
            AppLog().warning("end but already in keep bottom")
            return
        }
        defer { offsetChange = nil }
        guard diff > 0 else {
            AppLog().debug("igrnoal \(diff)")
            return
        }

        var offset = contentOffset
        offset.y += diff
        super.contentOffset = offset
        AppLog().debug("\(debugText) <= after update offset")
    }
     */

    private(set) var keepBottomVisiableCell: (some UITableViewCell, IndexPath)?
}
