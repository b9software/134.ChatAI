//
//  ConversationCell.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import AppFramework
import UIKit

class ConversationCell:
    UITableViewCell,
    HasItem,
    ConversationUpdating
{
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = TintBackgroundView().tintAlpha(0.4)
        focusEffect = UIFocusHaloEffect()
    }

    var item: Conversation! {
        didSet {
            oldValue?.delegates.remove(self)
            item?.delegates.add(self)
            updateUI()
        }
    }

    func updateUI() {
        guard let item = item else { return }
        conversationListStateChanged(item)
    }

    @IBOutlet private weak var nameLabel: UILabel!

    func conversationListStateChanged(_ item: Conversation) {
        nameLabel.text = item.name
    }
}
