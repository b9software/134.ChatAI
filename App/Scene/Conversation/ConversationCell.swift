//
//  ConversationCell.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class ConversationCell:
    UITableViewCell,
    HasItem,
    ConversationUpdating
{
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = {
            let bgView = UIView()
            bgView.backgroundColor = .tintColor.withAlphaComponent(0.4)
            return bgView
        }()
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

class ConversationEntityCell:
    UITableViewCell,
    HasItem
{
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = {
            let bgView = UIView()
            bgView.backgroundColor = .tintColor.withAlphaComponent(0.4)
            return bgView
        }()
    }

    var item: CDConversation! {
        didSet {
            nameLabel.text = item.title ?? L.Chat.defaultTitle
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
}
