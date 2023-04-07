//
//  ErrorLabel.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/7.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {

    func set(error msg: String?) {
        text = msg
        isHighlighted = true
        Current.osBridge.beep()
    }

    func set(normal msg: String?) {
        text = msg
        isHighlighted = false
    }
}
