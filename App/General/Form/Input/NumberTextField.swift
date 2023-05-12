//
//  NumberTextField.swift
//  B9ChatAI
//
//  Created by BB9z on 2023/5/12.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class IntegerTextField: UITextField {
    var value: Int? {
        get {
            if let content = text?.trimmed() {
                return Int(content)
            }
            return nil
        }
        set {
            text = newValue?.description
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(onEditingChanged), for: .editingChanged)
    }

    @IBAction private func onEditingChanged(_ sender: Any) {
        var normlized = ""
        if let content = text?.trimmed(),
           let value = Int(content) {
            normlized = String(value)
        }
        if text != normlized {
            text = normlized
            isInvalidPlaceholderMode = true
        } else {
            isInvalidPlaceholderMode = false
        }
    }

    var isInvalidPlaceholderMode = false {
        didSet {
            if oldValue == isInvalidPlaceholderMode { return }
            if isInvalidPlaceholderMode {
                if normalPlaceholder == nil {
                    normalPlaceholder = placeholder
                }
                placeholder = invalidPlaceholder
            } else {
                placeholder = normalPlaceholder
            }
        }
    }
    @IBInspectable var invalidPlaceholder: String?
    private var normalPlaceholder: String?
}
