/*
 MBScrollViewContentOffsetControl
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

@class MBScrollViewContentOffsetObserver;

// @MBDependency:2
/**
 监听 scrollView 的滚动，分发给多个监听代码
 */
@interface MBScrollViewContentOffsetControl : NSObject <
    RFInitializing
>
@property (weak, nonatomic, nullable) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL enabled;

#pragma mark - 当前状态

/// 用户上次结束滚动时的偏移
@property (readonly, nonatomic) CGPoint lastOffset;

/// 向一个方向连续移动的距离
@property (readonly, nonatomic) CGPoint continuousOffset;

/// 重置 lastOffset、continuousOffset 状态
- (void)reset;

#pragma mark -

- (nonnull MBScrollViewContentOffsetObserver *)addObserverPassingTest:(nonnull BOOL (^)( MBScrollViewContentOffsetControl * __nonnull control, CGPoint contentOffset))testBlock execution:(nonnull void (^)( MBScrollViewContentOffsetControl * __nonnull control, CGPoint contentOffset))executionBlock;
- (void)removeObserver:(nullable MBScrollViewContentOffsetObserver *)observer;

@end


@interface MBScrollViewContentOffsetObserver : NSObject

/// 可以快速禁用一个监听，免于卸载、重装
@property BOOL enabled;

/// 测试 block，返回 BOOL 决定是否应该执行 execution 回调
@property (nonnull) BOOL (^testBlock)(MBScrollViewContentOffsetControl * __nonnull control, CGPoint contentOffset);

/// 测试通过时调用的 block
@property (nonnull) void (^execution)(MBScrollViewContentOffsetControl * __nonnull control, CGPoint contentOffset);

@end
