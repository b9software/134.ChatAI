//
//  OpacityTouchView.swift
//  B9ChatAI
//
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

class OpacityTouchView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self {
            return nil
        }
        return result
    }
}
