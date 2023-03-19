/*
 MBLayoutButton
 
 Copyright © 2018-2019 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFAlpha/RFButton.h>

// @MBDependency:3

/**
 自定义元素布局的 button
 */
@interface MBLayoutButton : RFButton

/**
 禁用点按效果
 */
@property IBInspectable BOOL touchEffectDisabled;

/**
 重写已实现按下效果
 */
- (void)touchDownEffect;

/**
 重写已实现手势抬起恢复效果
 */
- (void)touchUpEffect;

/**
 点击放大倍数

 默认 1.1
 */
@property (nonatomic) IBInspectable CGFloat scale;

@property (nonatomic) IBInspectable float touchDuration;
@property (nonatomic) IBInspectable float releaseDuration;

@property IBInspectable BOOL reduceAlphaWhenDisabled;

/**
 跳转链接
 
 如果设置了 touchUpInsideCallback，默认的点击跳转不会被执行
 */
@property IBInspectable NSString *jumpURL;

@end
