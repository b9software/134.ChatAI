/*
 MBBottomLayoutView
 
 Copyright © 2019 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:4
/**
 符合官方 HIG 的底部按钮容器，对齐 safe area
 
 在异形屏幕上（如 iPhone X, iPad Pro），内容与屏幕边缘空出，并切圆角；
 在规整的矩形屏幕上，内容与屏幕边缘挨着。
 
 其他特性：
 - 隐藏时自动调整边距
 
 使用；
 - 在 IB 中设置底部距 safe area 或 bottom layout guide 的距离
 - 如果会隐藏，可能需要设置 heightConstraint 和 hiddenMoveTopAnchor 属性以便在隐藏时调整布局
 - 当前实现未考虑代码动态修改属性，
 
 */
@interface MBBottomLayoutView: UIView <
    RFInitializing
>

/**
 当前是否已应用裁切

 正常无需手动设置，布局确定后自动设置，调用 setter 可强制应用
 */
@property (nonatomic) BOOL clipping;

/**
 当内容不贴着屏幕时，需要裁切视图区域，这个属性控制裁切时的圆角
 
 默认 CGFLOAT_MAX（左右裁切为圆形），实际裁切的圆角不会超出视图高度的一半
 */
@property IBInspectable CGFloat clippingCornerRadius;

/**
 当内容不贴着屏幕时，左右空出的边距
 
 默认 15
 */
@property IBInspectable CGFloat clippingMargin;

/**
 自身高度的约束，可选设置
 
 如设置，在视图隐藏时自动禁用该约束，显示时会重新激活
 */
@property (nullable) IBOutlet NSLayoutConstraint *heightConstraint;

/**
 调整隐藏时之前对齐视图顶部的其他视图的对齐
 
 默认 NO，对齐 safe layout guide；YES 时对齐父视图底部
 */
@property IBInspectable BOOL hiddenMoveTopAnchor;

@end
