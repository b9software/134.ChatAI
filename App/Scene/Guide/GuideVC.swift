//
//  GuideVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .guide }

    override func viewDidLoad() {
        super.viewDidLoad()
        articleList.listDataSource.items = [
            Article(title: L.Guide.gptBestPractices, link: L.Guide.gptBestPracticesLink),
            Article(title: L.Guide.stephenWolfram202302, link: L.Guide.stephenWolfram202302Link),
        ]
    }

    private var articleList: ArticleListDisplayer! { articleContainer.embedViewController as? ArticleListDisplayer }
    @IBOutlet private weak var articleContainer: RFContainerView!
}
