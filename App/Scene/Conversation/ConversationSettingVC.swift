//
//  ConversationSettingVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class ConversationSettingViewController:
    UIViewController,
    StoryboardCreation,
    HasItem,
    ConversationUpdating
{
    static var storyboardID: StoryboardID { .conversation }

    var item: Conversation! {
        didSet {
            title = item.name
            item.delegates.add(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stateLabel.text = nil
        if item.usableState == .forceSetup {
            cancelButton.isHidden = true
            stateLabel.text = L.Chat.setupBeforeUseNotice
        }
        basicInfo.updateUI(item: item)
    }

    @IBOutlet private weak var basicInfo: CSBasicInfoScene!

    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!

    @IBAction private func onSubmit(_ sender: Any) {
        dismiss()
    }

    deinit {
        debugPrint("ConversationSettingViewController deinit")
    }
}

extension ConversationSettingViewController {
    static func showFrom(detail: ConversationDetailViewController) {
        let vc = ConversationSettingViewController.newFromStoryboard()
        vc.item = detail.item
        detail.addChild(vc)
        detail.view.addSubview(vc.view, resizeOption: .fill)
    }

    func dismiss() {
        removeFromParent()
        view.removeFromSuperview()
    }

    @IBAction private func onCancel(_ sender: Any) {
        dismiss()
    }
}

class CSBasicInfoScene: UIView {
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var idField: UITextField!
    @IBOutlet private weak var enginePicker: UITableView!
    private lazy var engineDataSource = CDFetchTableViewDataSource<CDEngine>()
    @IBOutlet private weak var modelPicker: UITableView!

    func updateUI(item: Conversation) {
        engineDataSource.tableView = enginePicker
        engineDataSource.fetchRequest = CDEngine.listRequest

        nameField.text = item.entity.title
        idField.placeholder = item.id
    }
}
