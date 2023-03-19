/*
 MBFixWidthImageView
 
 Copyright © 2018-2019 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>

// @MBDependency:3
/**
 等比例显示的，高度自适应的 image view
 
 Auto layout 下，image view 的 intrinsicContentSize 会与图像尺寸保持一致，当图像尺寸较小时，一切都很好。
 但当图像被压缩时，比如宽度受限且 contentMode 是 UIViewContentModeScaleAspectFit 时，高度依旧是原始尺寸，但宽度被压缩了，视图上下就会留有空白。这个类就在这方面进行了优化。
 */
@interface MBFixWidthImageView : UIImageView

/**
 未设置图片时默认的高宽比
 */
@property IBInspectable CGFloat defaultSizeRatio;

/**
 未设置图片时返回 no intrinsic size
 
 优先级低于 defaultSizeRatio
 */
@property IBInspectable BOOL perfersNoIntrinsicMetric;
@end
