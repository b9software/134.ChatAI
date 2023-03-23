//
//  WindowContext.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

extension NSToolbar {
    static func of(_ view: UIView) -> NSToolbar? {
        view.window?.windowScene?.titlebar?.toolbar
    }
}

extension SceneDelegate {
    static func of(_ view: UIView) -> Self? {
        view.window?.windowScene?.delegate as? Self
    }
}

extension RootViewController {
    static func of(_ view: UIView) -> Self? {
        view.window?.rootViewController as? Self
    }
}

class TestViewController: UIViewController {
    @IBOutlet private weak var aSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        aSwitch.preferredStyle = .checkbox
    }
}
