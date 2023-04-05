//
//  AutoListView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

/**
 Changes:

 - canBecomeFirstResponder
 - intrinsicContentSize follows content size
 */
class AutoListView: UITableView {
    override var canBecomeFirstResponder: Bool { true }

    private var contentSizeObserver: NSKeyValueObservation? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var trackedContentSize: CGSize? {
        didSet {
            if oldValue == trackedContentSize { return }
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        contentSize
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            contentSizeObserver = observe(\.contentSize, options: [.new, .initial]) { [weak self] _, _ in
                self?.trackedContentSize = self?.contentSize
            }
        } else {
            contentSizeObserver = nil
        }
    }
}
