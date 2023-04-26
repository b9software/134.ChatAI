//
//  Touchbar.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

class TouchbarController: NSObject, NSTouchBarDelegate {
    func makeTouchbar(items: [NSTouchBarItem.Identifier], template: Set<NSTouchBarItem>? = nil) -> NSTouchBar {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.defaultItemIdentifiers = items
        if let template = template {
            bar.templateItems = template
        }
        return bar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .back:
            let item = NSButtonTouchBarItem(identifier: identifier, image: Asset.GeneralUI.Navigation.navBack.image, target: nil, action: #selector(StandardActions.goBack))
            item.customizationLabel = L.Menu.navigationBack
            return item
        case .chatSettingBar:
            let item = NSPopoverTouchBarItem(identifier: identifier)
            item.collapsedRepresentationImage = .systemSliderVertical
            item.collapsedRepresentationLabel = L.Menu.settingChat
            item.popoverTouchBar = makeTouchbar(items: [.chatTemperature, .chatSettingMore], template: touchBar.templateItems)
            return item
        case .chatTemperature:
            assert(false)
            return NSSliderTouchBarItem(identifier: identifier)
        case .chatSettingMore:
            return NSButtonTouchBarItem(identifier: identifier, image: .systemSliderVertical, target: nil, action: #selector(ConversationDetailViewController.toggleSetting))
        default:
            fatalError()
        }
    }
}

extension NSTouchBarItem.Identifier {
    static let back = NSTouchBarItem.Identifier("app.back")
    static let chatSettingBar = NSTouchBarItem.Identifier("app.chat.setting-bar")
    static let chatTemperature = NSTouchBarItem.Identifier("app.chat.setting.temperature")
    static let chatSettingMore = NSTouchBarItem.Identifier("app.chat.setting.more")
}

#endif
