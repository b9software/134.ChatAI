/*
 MBSkyImageView

 Copyright © 2018, 2020 RFUI.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBImageView.h"

// @MBDependency:1
/**
 image view 的内容跟随 scrollView 滚动而滚动，像是吸附在 scrollView 上

 原理是随着 scrollView 的 contentOffset Y 轴变化而调整 view 的高度
 */
@interface MBSkyImageView : MBImageView <
    RFInitializing
>

///
@property (weak, nullable, nonatomic) IBOutlet UIScrollView *scrollView;

/// view 高度和 contentOffset 偏移量的调节
@property IBInspectable CGFloat offsetAdjust;

/// view 最小高度
@property IBInspectable CGFloat minimalHeight;

/// 距父 view 底部的距离保持不变
@property IBInspectable BOOL resizeTowardsTop;
@end
