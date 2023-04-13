//
//  GuideVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .guide }

    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = L.Guide.text1st
    }
}
