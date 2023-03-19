//
//  SplitViewController.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/3/20.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        preferredDisplayMode = .oneBesideSecondary
        primaryBackgroundStyle = .sidebar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let objects = UINib(nibName: "Toolbar", bundle: nil).instantiate(withOwner: nil)
        print(objects)
    }

    var navigator: NavigationController! {
        viewController(for: .secondary) as? NavigationController
    }

    @IBAction func gotoSettings(_ sender: Any) {
        navigator?.setViewControllers([SettingViewController.newFromStoryboard()], animated: false)
    }

    @IBAction func gotoGuide(_ sender: Any) {
        navigator?.setViewControllers([GuideViewController.newFromStoryboard()], animated: false)
    }
}
