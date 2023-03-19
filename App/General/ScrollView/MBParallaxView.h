/*
 MBParallaxView
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 跟随 scrollView 滚动而滚动的 view

 备忘：

 应该有两种模式，一种 frame 不变，内容跟随移动；一种内容保持不变，frame 跟随移动
 
 Parallax offset 其实就是自身的 content offset
 */
@interface MBParallaxView : UIScrollView <
    RFInitializing
>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/**
 scrollView contentOffset 的计算偏移量
 */
@property (nonatomic) IBInspectable CGPoint contentOffsetAdjust;

/**
 默认 1
 */
@property (nonatomic) IBInspectable CGFloat acceleration;

@property (nonatomic) IBInspectable CGPoint minParallaxOffset;
@property (nonatomic) IBInspectable CGPoint maxParallaxOffset;

/**
 如果非 { 0, 0 } 当监听到 scrollView 的 contentOffset 变化时强制设置成给定的值
 */
@property (nonatomic) CGPoint lockedContentOffset;

/**
 重写以改变效果
 */
- (void)updateLayoutForParallaxOffset:(CGPoint)offset;

- (CGPoint)parallaxOffsetFromScrollViewContentOffset:(CGPoint)contentOffset;
- (CGPoint)scrollViewContentOffsetFromParallaxOffset:(CGPoint)parallaxOffset;

/**
 在 MBParallaxView bounds 外的元素都是不可点击的
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
