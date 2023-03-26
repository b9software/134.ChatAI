//
//  EngineManageVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData
import UIKit

class EngineManageViewController: UIViewController {

    @IBOutlet private weak var typeButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        createContentView.setCollapsed(true, animated: false)
    }

    @IBAction private func onTypeSelection(_ sender: Any) {
        debugPrint(sender)
    }

    // MARK: - Create
    @IBOutlet private weak var createHeaderView: MBCollapsibleView!
    @IBOutlet private weak var createContentView: MBCollapsibleView!

    @IBAction private func onBeginCreate(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [self] in
            createHeaderView.setCollapsed(true, animated: false)
            createContentView.setCollapsed(false, animated: false)
            view.layoutIfNeeded()
        }
        dispatch_after_seconds(1) { [self] in
            debugPrint(createHeaderView.isCollapsed)
            debugPrint(createHeaderView.intrinsicContentSize)
        }
    }
    @IBAction private func onCancelCreate(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [self] in
            createHeaderView.setCollapsed(false, animated: false)
            createContentView.setCollapsed(true, animated: false)
            view.layoutIfNeeded()
        }
    }
}
