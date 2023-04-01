//
//  EngineCellView.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/1.
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class EngineCellView: UIView, HasItem {
    var item: CDEngine! {
        didSet {
            nameLabel.text = item.name
            if let type = Engine.EType(rawValue: item.type ?? "?") {
                typeLabel.text = type.displayString
            } else {
                typeLabel.text = "Unsupported: \(item.type ?? "?")"
            }
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
}
