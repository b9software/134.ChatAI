/*!
 MBTabControl
 
 Copyright © 2018-2020 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBControlGroup.h"

@class MBTabScrollView;

// @MBDependency:3
/**
 标签页容器
 */
@interface MBTabControl : MBControlGroup

#pragma mark - Paging scroll view

#if __has_include("MBTabScrollView.h")
/**
 如果设置了该属性，tab control 的选中状态会跟着 scroll view 自动联动—— scroll view 滚动，tab control 切换状态跟着变；tab control 选中切换，scroll view 切换到相应页
 */
@property (weak, nullable, nonatomic) IBOutlet MBTabScrollView *tabScrollView;
#endif

/**
 切换速度，默认 0，无切换动画
 */
@property (nonatomic) IBInspectable float pageScrollDuration;

#pragma mark - Indicating Image

/**
 是否显示 tab 底部的指示器
 
 默认 NO，目前只支持初始化时设置
 */
@property (nonatomic) IBInspectable BOOL indicatorEnabled;

@property (nullable, nonatomic) UIImageView *indicatingImageView;

@property (nonatomic) IBInspectable CGFloat indicatorBottomSpacing;

/// 默认 2
@property (nonatomic) IBInspectable CGFloat indicatingImageBottomHeight;

/// 打开，指示线与按钮同宽，此时 indicatingImageExpand 用于调节差量
@property (nonatomic) IBInspectable BOOL indicatingImageWidthSameAsButton;

/**
 indicatingImage 的宽度与标题宽度有关，这个量是标题两侧扩展的量

 默认 2
 */
@property (nonatomic) IBInspectable CGFloat indicatingImageExpand;

/// 2.8.16+ 指定指示线宽度
@property (nonatomic) IBInspectable CGFloat indicatingImageWidth;

- (void)updateIndicatingImage;

- (void)updateIndicatingImageViewFrame;

@end
