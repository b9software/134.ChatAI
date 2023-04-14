//
//  AboutVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import Foundation

class AboutViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .setting }

    @IBOutlet private weak var privacyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        privacyLabel.text = L.App.privacySort
    }

    @IBAction private func goGitHub(_ sender: Any) {
        UIApplication.shared.open(URL(string: L.App.homePage)!)
    }

    @IBAction private func gotoOpenAIPrivacy(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://openai.com/policies/privacy-policy")!)
    }

    @IBAction private func gotoOpenAITerms(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://openai.com/policies/terms-of-use")!)
    }
}
