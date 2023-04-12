//
//  EngineCellView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class EngineCellView: UIView, HasItem {
    var item: Engine! {
        didSet {
            typeLabel.text = item?.type.displayString
            nameLabel.text = item?.name
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
}
