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
        let selectIdx = Current.osBridge.theme
        for (idx, item) in themeButton.menu!.children.enumerated() {
            (item as? UICommand)?.state = selectIdx == idx ? .on : .off
        }
        if let idx = fontSizeCategoryMap.firstIndex(of: Current.defualts.preferredContentSize) {
            fontSizeSlider.value = Float(idx)
        }
        sendBySegment.selectedSegmentIndex = Current.defualts.preferredSendbyKey
        updateSendbyTitle()
    }

    @IBOutlet private weak var themeButton: UIButton!
    @IBAction private func onThemeSystem(_ sender: UICommand) {
        Current.defualts.preferredTheme = 0
        Current.osBridge.theme = 0
    }
    @IBAction private func onThemeLight(_ sender: UICommand) {
        Current.defualts.preferredTheme = 1
        Current.osBridge.theme = 1
    }
    @IBAction private func onThemeDark(_ sender: UICommand) {
        Current.defualts.preferredTheme = 2
        Current.osBridge.theme = 2
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

    @IBOutlet private weak var sendbyKeyLabel: UILabel!
    @IBOutlet private weak var sendBySegment: UISegmentedControl!
    @IBAction private func onSendBySegmentChange(_ sender: Any) {
        Current.defualts.preferredSendbyKey = sendBySegment.selectedSegmentIndex
        updateSendbyTitle()
    }
    private func updateSendbyTitle() {
        let keyDesc: String
        switch Current.defualts.preferredSendbyKey {
        case 0:
            keyDesc = "Command+Enter"
        case 1:
            keyDesc = "Shift+Enter"
        case 2:
            keyDesc = "Enter"
        default:
            keyDesc = "❓"
        }
        sendbyKeyLabel.text = keyDesc
    }
}
