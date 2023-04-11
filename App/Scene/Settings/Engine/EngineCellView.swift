//
//  EngineCellView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import HasItem
import UIKit

class EngineCellView: UIView, HasItem {
    var item: CDEngine! {
        didSet {
            if let item = item {
                asyncLoad(item: item)
            } else {
                nameLabel.text = nil
                typeLabel.text = nil
            }
        }
    }

    func asyncLoad(item: CDEngine) {
        Current.database.async { [weak self] _ in
            guard let sf = self,
                  sf.item === item else { return }
            let name = item.name
            let typeDesc: String
            if let type = Engine.EType(rawValue: item.type ?? "?") {
                typeDesc = type.displayString
            } else {
                typeDesc = "Unsupported: \(item.type ?? "?")"
            }
            sf.updateUI(name: name, type: typeDesc, flag: item)
        }
    }

    func updateUI(name: String?, type: String?, flag: CDEngine) {
        dispatch_async_on_main { [self] in
            if flag !== item { return }
            nameLabel.text = name
            typeLabel.text = type
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
}
