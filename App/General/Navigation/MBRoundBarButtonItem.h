/*
 MBRoundBarButtonItem
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <UIKit/UIKit.h>

// @MBDependency:1
/**
 MBRoundBarButtonItem 与普通 UIBarButtonItem 使用方式一样，运行时会带圆角背景。如果用正常的 UIBarButtonItem 来实现会比较麻烦，IB 中 拖 view 加 UIButton，连线，尺寸还不好调。
 
 目前实现比较简单，有需求再扩展：
 - 默认背景色由 tintColor 控制，文字默认是白色
 - 按钮偏移做了匹配，点击区域做了优化
 - 初始尺寸随文字自适应，文字变更的调整没做
 - 圆角、字体大小等都是写死的
 - 不支持代码创建
 
 */
@interface MBRoundBarButtonItem : UIBarButtonItem

/// 从 nib 中载入后设置，供外观定制
@property (readonly, nullable) UIButton *buttonView;
@end
