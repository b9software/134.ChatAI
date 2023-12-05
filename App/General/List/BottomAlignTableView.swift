//
//  BottomAlignTableView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class BottomAlignTableView: UITableView {

    override var contentSize: CGSize {
        didSet {
            if oldValue == contentSize {
                return
            }
            debug("contentSize: \(oldValue) => \(contentSize)")
            adjustContentInset()

            let yDiff = contentSize.height - oldValue.height
            var offset = contentOffset
            offset.y += yDiff
            if offset.y < -safeAreaInsets.top {
                debug("reach top, skip")
                return
            }
            debug("will adjust offset: \(offset)")
            contentOffset = offset
//            if yDiff < 0 {
            ignoralNextOffsetUpdate = CFAbsoluteTimeGetCurrent()
            debug("set ignoralNextOffsetUpdate")
//            }
        }
    }

    private var ignoralNextOffsetUpdate: CFAbsoluteTime = 0
    override var contentOffset: CGPoint {
        get {
            super.contentOffset
        }
        set {
            if ignoralNextOffsetUpdate > 0 {
                if CFAbsoluteTimeGetCurrent() - ignoralNextOffsetUpdate < 1e-3 {
                    debug("contentOffset: ignoral system adjust")
                    return
                }
                ignoralNextOffsetUpdate = 0
            }
            let oldValue = super.contentOffset
            super.contentOffset = newValue
            if oldValue.y != newValue.y {
                debug("contentOffset: \(oldValue.y) => \(newValue.y)")
            }
        }
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        adjustContentInset()
    }

    private func adjustContentInset() {
        let oldValue = contentInset.top
        let newValue = max(bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - contentSize.height, 0)
        if abs(newValue - oldValue) < 1 {
            return
        }
        var inset = contentInset
        inset.top = newValue
        contentInset = inset
        debug("adjust inset: \(inset)")
    }

    private func debug(_ value: @autoclosure () -> CustomStringConvertible) {
//        print(value().description)
    }
}
