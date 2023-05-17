//
//  EngineCreateVCs.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/4/25.
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

struct EngineCreateItem {
    var name: String
    var detail: String
    var type: Engine.EType
}

class EngineCreateTypeCell: UICollectionViewCell {
    var item: EngineCreateItem! {
        didSet {
            nameLabel.text = item.name
            detailLabel.text = item.detail
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
}

class EngineCreateTypeViewController:
    UIViewController,
    UICollectionViewDataSource,
    StoryboardCreation
{
    static var storyboardID: StoryboardID { .setting }

    @IBOutlet private weak var listView: UICollectionView!

    private lazy var listItem: [EngineCreateItem] = [
        .init(name: L.Engine.Create.TypeOpenai.title, detail: L.Engine.Create.TypeOpenai.detail, type: .openAI),
        .init(name: L.Engine.Create.TypeOpenaiProxy.title, detail: L.Engine.Create.TypeOpenaiProxy.detail, type: .openAIProxy),
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listItem.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = listItem[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.type.rawValue, for: indexPath) as? EngineCreateTypeCell else {
            fatalError()
        }
        cell.item = item
        return cell
    }
}


class EngineCreateOpenAIViewController: UIViewController {
    @IBOutlet private weak var apiKeyField: UITextField!
    @IBOutlet private weak var apiKeySubmitButton: UIButton!
    @IBOutlet private weak var logLabel: LogLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        logLabel.clear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        createTask?.cancel()
    }

    @IBAction private func onSubmit(_ sender: Any) {
        guard let key = apiKeyField.text?.trimmed() else {
            logLabel.x(.warning, L.Engine.Create.noKeyGiven)
            return
        }
        logLabel.clear()
        apiKeyField.isEnabled = false
        apiKeySubmitButton.isEnabled = false
        apiKeySubmitButton.configuration?.showsActivityIndicator = true
        let item = OAEngine()
        item.apiKey = key
        createTask = Engine.create(engine: item, logHandler: logLabel, completion: { [weak self] result in
            self?.createDone(result: result)
        })
    }

    private func createDone(result: Result<Engine, Error>) {
        if result.isSuccess {
            apiKeyField.text = nil
            dispatch_after_seconds(2) { [weak self] in
                guard let sf = self else { return }
                sf.navigationController?.removeViewController(sf, animated: true)
            }
            return
        }
        apiKeyField.isEnabled = true
        apiKeySubmitButton.configuration?.showsActivityIndicator = false
        apiKeySubmitButton.isEnabled = true
    }

    private var createTask: Task<Void, Never>?

    @IBAction private func openKeyURL(_ sender: Any) {
        URL.open(link: L.Link.Openai.apiKeys)
    }
}


class EngineCreateProxyViewController:
    UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        sendKeySwitch.isOn = false
        keyField.isHidden = true
        advancedButton.isSelected = false
        advancedContainer.isHidden = true
        logLabel.clear()
        onAddressChanged(self)
        if L.Link.Openai.knownProxy.isEmpty {
            knownLinkContianer.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        createTask?.cancel()
    }

    @IBOutlet private weak var content: UIView!
    @IBOutlet private weak var addressField: UITextField!
    @IBOutlet private weak var sendKeySwitch: UISwitch!
    @IBOutlet private weak var keyField: UITextField!

    @IBOutlet private weak var advancedButton: UIButton!
    @IBOutlet private weak var advancedContainer: UIView!
    @IBOutlet private weak var completionEndpointField: UITextField!
    @IBOutlet private weak var modelEndpointField: UITextField!

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var logLabel: LogLabel!

    @IBAction private func onSendKeySwitchChanged(_ sender: Any) {
        UIView.animate(withDuration: 0.2) { [self] in
            keyField.isHidden = !sendKeySwitch.isOn
            view.layoutIfNeeded()
        }
    }

    @IBAction private func onAdvancedButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2) { [self] in
            advancedButton.isSelected.toggle()
            advancedContainer.isHidden = !advancedButton.isSelected
            view.layoutIfNeeded()
        }
    }

    private func normalizedBase() -> String {
        var text = addressField.text?.trimmed() ?? "https://proxy-address.com"
        if !text.hasPrefix("http") {
            text = "https://" + text
        }
        if text.hasSuffix("/") {
            _ = text.dropLast(1)
        }
        return text
    }

    @IBAction private func onAddressChanged(_ sender: Any) {
        let base = normalizedBase()
        completionEndpointField.placeholder = base + "/v1/completions"
        modelEndpointField.placeholder = base + "/v1/models"
    }

    @IBAction private func onSubmit(_ sender: Any) {
        logLabel.clear()
        guard let _ = addressField.text?.trimmed(),
              let address = URL(string: normalizedBase()) else {
            logLabel.x(.warning, L.Engine.Create.noProxyAddressGiven)
            return
        }

        let item = OAEngine()
        item.baseURL = address
        if sendKeySwitch.isOn {
            guard let key = keyField.text?.trimmed() else {
                logLabel.x(.warning, L.Engine.Create.noKeyGiven)
                return
            }
            item.apiKey = key
        }
        if let value = completionEndpointField.text?.trimmed() {
            guard let url = URL(string: value) else {
                logLabel.x(.error, L.GenralError.invalidUrl(value))
                return
            }
            item.customCompletionURL = url
        }
        if let value = modelEndpointField.text?.trimmed() {
            guard let url = URL(string: value) else {
                logLabel.x(.error, L.GenralError.invalidUrl(value))
                return
            }
            item.customListModelURL = url
        }

        content.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        submitButton.configuration?.showsActivityIndicator = true

        createTask = Engine.createProxy(engine: item, logHandler: logLabel, completion: { [weak self] result in
            self?.createDone(result: result)
        })
    }

    private func createDone(result: Result<Engine, Error>) {
        submitButton.isEnabled = true
        submitButton.configuration?.showsActivityIndicator = false
        if result.isSuccess {
            dispatch_after_seconds(2) { [weak self] in
                guard let sf = self else { return }
                sf.navigationController?.removeViewController(sf, animated: true)
            }
            return
        }
        content.isUserInteractionEnabled = true
    }

    private var createTask: Task<Void, Never>?

    @IBOutlet private weak var knownLinkContianer: UIView!
    @IBAction private func onOpenKnownURL(_ sender: Any) {
        URL.open(link: L.Link.Openai.knownProxy)
    }
}
