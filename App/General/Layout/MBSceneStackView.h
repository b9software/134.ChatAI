/*
 MBSceneStackView
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 基于 UIStackView 的界面切换
 
 把 UIStackView 中的 view 分成若干组，每次显示一组，并支持组间切换显示
 */
@interface MBSceneStackView : UIStackView

@property (readonly) NSInteger activeSceneIndex;
@property (nonatomic, nullable) NSArray<NSArray<UIView *> *> *scenes;

- (void)setActiveSceneWithIndex:(NSInteger)index animated:(BOOL)animated;

- (void)nextSceneAnimated:(BOOL)animated;
- (void)previousSceneAnimated:(BOOL)animated;

@property (nullable) void (^onSceneChanged)(MBSceneStackView *__nonnull stackView, NSInteger activeSceneIndex);

@end
