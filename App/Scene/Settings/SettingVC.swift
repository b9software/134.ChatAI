//
//  SettingVC.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .setting }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: UserDefaults.didChangeNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc private func updateUI() {
        var selectIdx = Current.osBridge.theme
        for (idx, item) in themeButton.menu!.children.enumerated() {
            (item as? UICommand)?.state = selectIdx == idx ? .on : .off
        }
        if let idx = fontSizeCategoryMap.firstIndex(of: Current.defualts.preferredContentSize) {
            fontSizeSlider.value = Float(idx)
        }
        selectIdx = Current.defualts.conversationSortBy.rawValue
        for (idx, item) in conversationOrderButton.menu!.children.enumerated() {
            (item as? UICommand)?.state = selectIdx == idx ? .on : .off
        }
        let sendby = Current.defualts.preferredSendbyKey
        sendBySegment.selectedSegmentIndex = sendby.rawValue
        sendbyKeyLabel.text = sendby.keyDescription
    }

    @IBOutlet private weak var themeButton: UIButton!
    @IBAction private func onThemeSystem(_ sender: UICommand) {
        Current.osBridge.theme = 0
        Current.defualts.preferredTheme = 0
    }
    @IBAction private func onThemeLight(_ sender: UICommand) {
        Current.osBridge.theme = 1
        Current.defualts.preferredTheme = 1
    }
    @IBAction private func onThemeDark(_ sender: UICommand) {
        Current.osBridge.theme = 2
        Current.defualts.preferredTheme = 2
    }

    @IBOutlet private weak var fontSizeSlider: UISlider! {
        didSet {
            fontSizeSlider.setThumbImage(Asset.GeneralUI.Control.tickSliderThumb.image, for: .normal)
            fontSizeSlider.maximumValue = Float(fontSizeCategoryMap.count - 1)
        }
    }
    @IBAction private func onFontSizeSliderChange(_ sender: Any) {
        fontSizeSlider.value = fontSizeSlider.value.rounded()
        let size = sizeCategory(value: Int(fontSizeSlider.value))
        Current.defualts.preferredContentSize = size
        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil, userInfo: [UIContentSizeCategory.newValueUserInfoKey: size])
    }
    private let fontSizeCategoryMap: [UIContentSizeCategory] = [
        .extraSmall,
        .small,
        .medium,
        .large,
        .extraLarge,
        .extraExtraLarge,
        .extraExtraExtraLarge,
        .accessibilityMedium,
        .accessibilityLarge,
    ]
    func sizeCategory(value: Int) -> UIContentSizeCategory {
        return fontSizeCategoryMap.element(at: value) ?? .medium
    }

    @IBOutlet private weak var conversationOrderButton: UIButton!
    @IBAction private func onConversationOrderCreate(_ sender: UICommand) {
        Current.conversationManager.changeListOrder(by: .createTime)
    }
    @IBAction private func onConversationOrderMessage(_ sender: UICommand) {
        Current.conversationManager.changeListOrder(by: .lastTime)
    }

    @IBOutlet private weak var sendbyKeyLabel: UILabel!
    @IBOutlet private weak var sendBySegment: UISegmentedControl!
    @IBAction private func onSendBySegmentChange(_ sender: Any) {
        let value = Sendby(rawValue: sendBySegment.selectedSegmentIndex) ?? {
            assert(false)
            return .command
        }()
        Current.defualts.preferredSendbyKey = value
        sendbyKeyLabel.text = value.keyDescription
    }
}
