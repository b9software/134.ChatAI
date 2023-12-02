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

#if targetEnvironment(macCatalyst)
extension NSToolbarController {
    static func of(_ view: UIView) -> NSToolbarController? {
        SceneDelegate.of(view)?.toolbarController
    }
}

extension TouchbarController {
    static func of(_ view: UIView) -> TouchbarController? {
        SceneDelegate.of(view)?.touchbarController
    }
}
#endif

extension RootViewController {
    static func of(_ view: UIView) -> Self? {
        view.window?.rootViewController as? Self
    }
}

class TestViewController: UIViewController {
    @IBOutlet private weak var segment: UISegmentedControl!

    @IBAction private func onSegmentChanged(_ sender: Any) {
        let category: UIContentSizeCategory
        switch segment.selectedSegmentIndex {
        case 1:
            category = .extraSmall
        case 2:
            category = .extraLarge
        default:
            category = .medium
        }
        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil, userInfo: [UIContentSizeCategory.newValueUserInfoKey: category])
    }
}
