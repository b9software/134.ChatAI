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

    override func awakeFromNib() {
        super.awakeFromNib()
        LiveCount(add: self, limit: 2)
    }

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
            stateLabel.set(normal: L.Chat.setupBeforeUseNotice)
        }
        basicInfo.updateUI(item: item)
        systemField.text = item.engineConfig.system
        updateTemperature(item.engineConfig.temperature)
        updateTopP(item.engineConfig.topP)
    }

    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var basicInfo: CSBasicInfoScene!

    @IBOutlet private weak var systemField: UITextView!
    @IBOutlet private weak var temperatureSlider: UISlider!
    @IBOutlet private weak var temperatureDescribeLabel: UILabel!
    @IBOutlet private weak var topProbabilitySlider: UISlider!
    @IBOutlet private weak var topProbabilityDescribeLabel: UILabel!

    @IBOutlet private weak var barContainer: UIView!
    @IBOutlet private weak var stateLabel: ErrorLabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!
}

extension ConversationSettingViewController {
    static func showFrom(detail: ConversationDetailViewController, animate: Bool) {
        let vc = ConversationSettingViewController.newFromStoryboard()
        vc.item = detail.item
        detail.addChild(vc)
        detail.view.addSubview(vc.view, resizeOption: .fill)
        vc.animateShown(animate: animate)
    }

    private func animateShown(animate: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, animated: animate, beforeAnimations: {
            var rect = contentContainer.bounds
            rect.origin.y = rect.height
            contentContainer.bounds = rect
            rect = barContainer.bounds
            rect.origin.y = -rect.height
            barContainer.bounds = rect
            contentContainer.alpha = 0
            barContainer.alpha = 0
        }, animations: { [self] in
            var rect = contentContainer.bounds
            rect.origin.y = 0
            contentContainer.bounds = rect
            rect = barContainer.bounds
            rect.origin.y = 0
            barContainer.bounds = rect
            contentContainer.alpha = 1
            barContainer.alpha = 1
        })
    }

    func dismiss(animate: Bool) {
        if !animate {
            removeFromParent()
            view.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [self] in
            var rect = contentContainer.bounds
            rect.origin.y = rect.height
            contentContainer.bounds = rect
            rect = barContainer.bounds
            rect.origin.y = -rect.height
            barContainer.bounds = rect
            contentContainer.alpha = 0
            barContainer.alpha = 0
        }, completion: { [self] _ in
            removeFromParent()
            view.removeFromSuperview()
        })
    }

    @IBAction private func onCancel(_ sender: Any) {
        if item.usableState == .forceSetup {
            stateLabel.set(error: L.Chat.setupBeforeUseNotice)
            return
        }
        dismiss(animate: true)
    }

    @IBAction private func onSubmit(_ sender: Any) {
        guard let engine = basicInfo.selectedEngine else {
            stateLabel.set(error: L.Chat.Setting.choiceEngine)
            return
        }
        guard let model = basicInfo.selectedModel else {
            stateLabel.set(error: L.Chat.Setting.choiceModel)
            return
        }
        let cfgChat = ChatConfig(
        )
        let cfgEngine = EngineConfig(
            model: model,
            system: systemField.text.trimmed(),
            temperature: temperatureSlider.value,
            topP: topProbabilitySlider.value
        )
        do {
            try item.save(
                name: basicInfo.nameField.text?.trimmed(),
                id: basicInfo.idField.text?.trimmed(),
                engine: engine,
                cfgChat: cfgChat,
                cfgEngine: cfgEngine
            )
            dismiss(animate: true)
        } catch {
            stateLabel.set(error: error.localizedDescription)
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(onCancel)),
            UIKeyCommand(input: "\r", modifierFlags: .command, action: #selector(onSubmit)),
        ]
    }
}

class CSBasicInfoScene: UIView, UITableViewDelegate {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet private weak var enginePicker: UITableView!
    private lazy var engineDataSource = CDFetchTableViewDataSource<CDEngine>(tableView: enginePicker)
    @IBOutlet private weak var engineEmptyView: UIView!
    @IBOutlet private var modelPickViews: [UIView]!
    @IBOutlet private weak var modelPicker: UITableView!
    private lazy var modelDataSource = GeneralSingleSectionListDataSource<String>(tableView: modelPicker, cellProvider: UITableView.cellProvider(_:indexPath:object:))
    @IBOutlet private weak var modelStateView: ListStateView!

    override func awakeFromNib() {
        super.awakeFromNib()
        engineDataSource.emptyView = engineEmptyView
    }

    func updateUI(item: Conversation) {
        engineDataSource.fetchCacheName = "engine_list"
        engineDataSource.keepsSelectionThroughIndexPaths = true
        engineDataSource.fetchRequest = CDEngine.listRequest
        modelPicker.dataSource = modelDataSource
        if let entity = item.engine?.entity {
            engineDataSource.selectedItems = [entity]
        }

        nameField.text = item.title
        idField.placeholder = item.id
        setEngine(item.engine, allowNull: true)
    }

    var selectedEngine: Engine? {
        didSet {
            debugPrint(#function, selectedEngine ?? "nil")
        }
    }
    var selectedModel: StringID? {
        didSet {
            debugPrint(#function, selectedModel ?? "nil")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == enginePicker {
            guard let entity = engineDataSource.item(at: indexPath) else {
                assert(false)
                return
            }
            setEngine(Engine.from(entity: entity), allowNull: false)
        } else if tableView == modelPicker {
            selectedModel = modelDataSource.item(at: indexPath)
            selectedEngine?.lastSelectedModel = selectedModel
        }
    }

    private func setEngine(_ engine: Engine?, allowNull: Bool) {
        selectedEngine = engine
        updateUIForEngineSelection()
        if selectedEngine == nil, !allowNull {
            modelStateView.state = .error(AppError.message(L.Chat.Setting.selectBadEngine))
        }
    }

    func updateUIForEngineSelection() {
        if let engine = selectedEngine {
            modelPickViews.views(hidden: false, animated: true)
            selectedModel = nil
            if engine.isValid {
                loadModels(engine: engine)
            } else {
                modelStateView.state = .error(AppError.message(L.Chat.Setting.engineMissingKey))
            }
            dispatch_after_seconds(0) { [weak self] in
                self?.scrollView.scrollToBottom(animated: true)
            }
        } else {
            modelPickViews.views(hidden: true)
        }
    }

    func loadModels(engine: Engine) {
        modelLoadTask = Task {
            do {
                setModelItems(engine.listModel())
                let newModels = try await engine.refreshModels().value
                setModelItems(newModels)
            } catch {
                Task { @MainActor in
                    modelStateView.state = .error(error)
                }
            }
        }
    }

    @MainActor func setModelItems(_ models: [String]?) {
        guard let models = models else {
            modelStateView.state = .loading(L.Chat.Setting.modelFetching)
            return
        }
        modelDataSource.update(listItems: models)
        modelStateView.state = .normal
        if let model = selectedEngine?.lastSelectedModel {
            modelDataSource.selectedItems = [model]
            selectedModel = model
        } else {
            modelDataSource.selectedItems = []
        }
    }

    private var modelLoadTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
}

class ModelNameSelectionCell: GeneralListCell {
    override var item: Any! {
        didSet {
            nameLabel.text = item as? String
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
}

extension ConversationSettingViewController {
    private func updateTemperature(_ value: FloatParameter) {
        if abs(temperatureSlider.value - value) > 0.01 {
            temperatureSlider.value = value
        }
        switch value {
        case 0..<0.33:
            temperatureDescribeLabel.text = L.Chat.Setting.temperatureTipLower
        case 0.33..<0.66:
            temperatureDescribeLabel.text = L.Chat.Setting.temperatureTipStand
        default:
            temperatureDescribeLabel.text = L.Chat.Setting.temperatureTipUpper
        }
    }

    @IBAction private func onTemperatureSliderChange() {
        updateTemperature(temperatureSlider.value)
    }

    private func updateTopP(_ value: FloatParameter) {
        if abs(topProbabilitySlider.value - value) > 0.01 {
            topProbabilitySlider.value = value
        }
        switch value {
        case 0..<0.5:
            topProbabilityDescribeLabel.text = L.Chat.Setting.topPossibleTipLower
        default:
            topProbabilityDescribeLabel.text = L.Chat.Setting.topPossibleTipUpper
        }
    }

    @IBAction private func onTopPSliderChange() {
        updateTopP(topProbabilitySlider.value)
    }
}
