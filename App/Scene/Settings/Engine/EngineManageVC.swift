//
//  EngineManageVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData
import UIKit

class EngineManageViewController:
    UIViewController,
    StoryboardCreation
{
    static var storyboardID: StoryboardID { .setting }

    @IBOutlet private weak var listView: EngineListView!

    override func viewDidLoad() {
        super.viewDidLoad()
        listView.fetchRequest = CDEngine.listRequest
    }
}
