/*
 MBImageRenderer
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 将 View Controller 的内容渲染为自适应尺寸的图片
 
 - 多用于复杂分享图片的生成
 - 在 Interface Builder 中进行可视化设计，并利用 Auto Layout 简化内容的自适应
 
 */
@interface MBImageRenderer : NSObject

- (null_unspecified instancetype)init NS_UNAVAILABLE;

/**
 @param viewController Must not be nil
 */
- (nonnull instancetype)initWithViewController:(nonnull UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

@property (readonly, nonnull) UIViewController *viewController;

/// 截图的 scale，默认为 2
@property CGFloat renderScale;

/**
 准备渲染，并更新布局
 
 布局分两种，如果 viewController 指定了非零的 preferredContentSize，则固定为该尺寸；
 否则需要用 Auto Layout 撑起 view 的尺寸（宽高都需要定义）
 
 这个方法可以反复调用。内部会把 view controller 的 view 安装到 keywindow 里
 */
- (void)prepareForRendering;

/**
 渲染出图，然后清理
 
 默认会先调用一次 prepareForRendering
 */
- (nullable UIImage *)renderAndClean;

@end
