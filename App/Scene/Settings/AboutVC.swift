//
//  AboutVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .setting }

    @IBOutlet private weak var privacyLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        privacyLabel.text = L.App.privacySort
        versionLabel.text = versionString()
    }

    private func versionString() -> String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        #if DEBUG
        let build = "DEBUG"
        #else
        let build = info?["CFBundleVersion"] as? String ?? "?"
        #endif
        return "v\(version) (Build \(build))"
    }

    @IBAction private func goGitHub(_ sender: Any) {
        URL.open(link: L.Link.homePage)
    }

    @IBAction private func gotoOpenAIPrivacy(_ sender: Any) {
        URL.open(link: L.Link.Openai.privacy)
    }

    @IBAction private func gotoOpenAITerms(_ sender: Any) {
        URL.open(link: L.Link.Openai.tos)
    }
}
