//
//  SettingVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .setting }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }

    private func updateUI() {
        let selectIdx = Current.osBridge.theme
        for (idx, item) in themeButton.menu!.children.enumerated() {
            (item as? UICommand)?.state = selectIdx == idx ? .on : .off
        }
    }

    @IBOutlet private weak var themeButton: UIButton!
    @IBAction private func onThemeSystem(_ sender: UICommand) {
        Current.defualts.preferredTheme = 0
        Current.osBridge.theme = 0
    }
    @IBAction private func onThemeLight(_ sender: UICommand) {
        Current.defualts.preferredTheme = 1
        Current.osBridge.theme = 1
    }
    @IBAction private func onThemeDark(_ sender: UICommand) {
        Current.defualts.preferredTheme = 2
        Current.osBridge.theme = 2
    }
}
