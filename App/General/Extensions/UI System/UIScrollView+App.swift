//
//  UIScrollView+App.swift
//  B9ChatAI
//
//  Created by Joseph Zhao on 2023/4/6.
//  Copyright © 2023 B9Software. All rights reserved.
//

import UIKit

extension UIScrollView {
    /// Make the receiver scroll to the top.
    func scrollToTop(animated: Bool) {
        let topRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        scrollRectToVisible(topRect, animated: animated)
    }

    /// Make the receiver scroll to the bottom.
    func scrollToBottom(animated: Bool) {
        let offsetY = contentSize.height - frame.height
        if offsetY > 0 {
            var offset = contentOffset
            offset.y = offsetY
            setContentOffset(offset, animated: animated)
        }
    }
}
