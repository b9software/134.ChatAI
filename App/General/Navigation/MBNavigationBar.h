/*
 MBNavigationBar
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:1
@interface MBNavigationBar : UINavigationBar <
    RFInitializing
>

// 原生的导航位置/平铺模式不好控制，如果不能轻易调好，需要很多奇怪的组合的话，往后系统改行为就坑了
// 不如写个自己的便于控制
@property (nonatomic, nullable, weak) UIImageView *customShadowImageView;
@end
