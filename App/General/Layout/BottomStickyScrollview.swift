//
//  BottomStickyScrollview.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/9.
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

class BottomStickyScrollview: UIScrollView {
    var debugText: String {
        String(format: "ox%5.1f, ct%5.1f, %@", contentOffset.y, contentSize.height, bounds.size.debugDescription)
    }

    override var bounds: CGRect {
        didSet {
            if contentSize.height > bounds.height {
                let diff = oldValue.height - bounds.height
                guard diff > 0 else { return }
                var offset = contentOffset
                offset.y += diff
                contentOffset = offset
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

    func beginKeepBottom(newContentSize: CGSize) {
        if newContentSize.height < bounds.height {
            return
        }
        if offsetChange != nil {
            AppLog().warning("begin but already in keep bottom")
            return
        }
        offsetChange = newContentSize.height - bounds.maxY
    }

    func endKeepBottom() {
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
        contentOffset = offset
        AppLog().debug("\(debugText) <= after update offset")
    }
}
