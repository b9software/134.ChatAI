//
//  WindowContext.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

extension SceneDelegate {
    static func of(_ view: UIView) -> Self? {
        view.window?.windowScene?.delegate as? Self
    }
}

extension NSToolbarController {
    static func of(_ view: UIView) -> NSToolbarController? {
        SceneDelegate.of(view)?.toolbarController
    }
}

extension RootViewController {
    static func of(_ view: UIView) -> Self? {
        view.window?.rootViewController as? Self
    }
}

class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet private weak var topDistance: NSLayoutConstraint!

    @IBAction private func onAdd(_ sender: Any) {
        topDistance.constant += 100
    }
    @IBAction private func onRemove(_ sender: Any) {
        topDistance.constant -= 50
    }

    @IBOutlet private weak var label: SelectableLabel!
}
