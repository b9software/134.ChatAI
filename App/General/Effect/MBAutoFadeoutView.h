/*
 MBAutoFadeoutView
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>
#import <RFInitializing.h>

// @MBDependency:2
/**
 显示出来后，默认一段时间隐藏
 
 只修改 alpha，不修改 hidden
 */
@interface MBAutoFadeoutView : UIView <
    RFInitializing
>

/// 指定显示出来后多久自动隐藏，默认 3s
@property (nonatomic) IBInspectable double fadeoutDelay;

/// 显示时的 alpha，默认 1
@property (nonatomic) IBInspectable CGFloat showAlpha;

/// 隐藏时的 alpha，默认 0
@property (nonatomic) IBInspectable CGFloat hideAlpha;

/// 显隐动画时间，默认 0.3s
@property (nonatomic) IBInspectable double fadeAnimationDuration;

///
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))completion;

@end
