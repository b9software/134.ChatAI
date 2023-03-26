/*
 MBDesignView

 Copyright © 2018, 2023 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

// @MBDependency:1
/**
 在 IB 中为了看清浅色元素或者为了标记区域，可以给 view 设置背景色，运行时再清空

 这个 view 会在 awakeFromNib 时自动清空背景色
 */
class MBDesignView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = nil
    }
}
