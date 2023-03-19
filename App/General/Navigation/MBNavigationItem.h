/*
 MBNavigationItem
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <UIKit/UIKit.h>

// @MBDependency:2
/**
 可以用另一个 UINavigationItem 设置 MBNavigationItem 的状态，并可以恢复原始状态
 
 典型场景：在表单页面，切换到不同的 field 时可能需要导航按钮呈现不同的状态，field 失去焦点时还原原始的状态。这个场景下 vc 使用 MBNavigationItem，不同的 field 关联响应的 UINavigationItem，就很好做。
 */
@interface MBNavigationItem : UINavigationItem

/**
 用 sorceItem 的属性设置 destinationItem
 */
+ (void)applyNavigationItem:(UINavigationItem *)sorceItem toNavigationItem:(UINavigationItem *)destinationItem animated:(BOOL)animated;

/// 将 MBNavigationItem 应用成另一个 navigationItem 的样子
- (void)applyNavigationItem:(UINavigationItem *)navigationItem animated:(BOOL)animated;

/// 还原 MBNavigationItem
- (void)restoreNavigationItemAnimated:(BOOL)animated;

@end
