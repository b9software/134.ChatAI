//
//  EngineManageVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import CoreData
import UIKit

class EngineManageViewController: UIViewController {

    @IBOutlet private weak var createView: EngineCreateView!
    @IBOutlet private weak var listView: EngineListView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createView.setupViews()
        listView.fetchRequest = CDEngine.listRequest
    }
}

class EngineCreateView: UIView {
    func setupViews() {
        contentView.setCollapsed(true, animated: false)
        typeScene.scenes = [
            [defaultTypeContainer],
            [apiContainer, logLabel],
            [proxyContainer],
        ]
        typeScene.setActiveScene(at: 0, animated: false)
    }

    @IBOutlet private weak var headerView: MBCollapsibleView!
    @IBOutlet private weak var contentView: MBCollapsibleView!

    @IBAction private func onBeginCreate(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [self] in
            headerView.setCollapsed(true, animated: false)
            contentView.setCollapsed(false, animated: false)
            layoutIfNeeded()
        }
    }
    @IBAction private func onCancelCreate(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { [self] in
            headerView.setCollapsed(false, animated: false)
            contentView.setCollapsed(true, animated: false)
            layoutIfNeeded()
        }
//        logLabel.clear()
        createTask?.cancel()
    }

    @IBOutlet private weak var typeScene: MBSceneStackView!
    @IBOutlet private weak var defaultTypeContainer: UIView!
    @IBOutlet private weak var apiContainer: UIView!
    @IBOutlet private weak var proxyContainer: UIView!
    @IBOutlet private weak var typeButton: UIButton!
    @IBOutlet private weak var logLabel: LogLabel!

    @IBAction private func onTypeApi(_ sender: Any) {
        typeScene.setActiveScene(at: 1, animated: true, layoutView: superview ?? self)
        logLabel.text = nil
    }
    @IBAction private func onTypeProxy(_ sender: Any) {
        typeScene.setActiveScene(at: 2, animated: true, layoutView: superview ?? self)
    }

    @IBOutlet private weak var apiKeyField: UITextField!
    @IBOutlet private weak var apiKeySubmitButton: UIButton!
    @IBAction private func onCreateApi(_ sender: UIButton) {
        guard let key = apiKeyField.text else {
            logLabel.text = "Please input a valid API key."
            return
        }
        logLabel.clear()
        apiKeyField.isEnabled = false
        sender.isEnabled = false
        sender.configuration?.showsActivityIndicator = true
        let item = OAEngine()
        item.apiKey = key
        createTask = Engine.create(engine: item, logHandler: logLabel, completion: { [weak self] result in
            self?.createDone(result: result)
        })
    }

    private func createDone(result: Result<Engine, Error>) {
        if result.isSuccess {
            apiKeyField.text = nil
            Current.database.container.viewContext.refreshAllObjects()
        }
        apiKeyField.isEnabled = true
        apiKeySubmitButton.configuration?.showsActivityIndicator = false
        apiKeySubmitButton.isEnabled = true
    }

    private var createTask: Task<Void, Never>?
}
