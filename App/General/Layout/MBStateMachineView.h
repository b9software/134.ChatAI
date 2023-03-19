/*
 MBStateMachineView
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <UIKit/UIKit.h>
#import <RFInitializing/RFInitializing.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBStateMachineViewDelegate;

// @MBDependency:2
/**
 划定一个区域，改变一个标识符，这块区域将显示不同的内容，这就是状态机 view 的作用

 frame 现在是固定的
 */
@interface MBStateMachineView : UIView <
    RFInitializing
>

/**
 状态变化时将指定状态的 view 显示出来

 为空时隐藏自身
 */
@property (nonatomic, nullable, copy) IBInspectable NSString *state;

/**
 各个状态的视图来源
 
 不为空时按照 viewForSTATE 的规则到 viewSource 中获取视图，如果获取到的对象不是 UIView 会断言失败
 
 为空时则查找自己的子视图
 */
@property (nonatomic, nullable, weak) IBOutlet id viewSource;

- (void)addDelegate:(nullable id<MBStateMachineViewDelegate>)aDelegate;
- (void)removeDelegate:(nullable id<MBStateMachineViewDelegate>)aDelegate;

@end


@protocol MBStateMachineViewDelegate <NSObject>

- (void)stateMachineView:(MBStateMachineView *)view didChangedStateFromState:(nullable NSString *)oldStats toState:(nullable NSString *)newState;

@end


@protocol MBStateMachineViewIdentifying
@optional
- (NSString *)stateIdentifier;

///
- (BOOL)dontResizeWhenStateChanged;
@end


/**
 默认只增加了一个属性
 */
@interface MBStateMachineSubview : UIView <
    MBStateMachineViewIdentifying
>
@property (nonatomic, copy) IBInspectable NSString *stateIdentifier;
@property (nonatomic) IBInspectable BOOL dontResizeWhenStateChanged;
@end

NS_ASSUME_NONNULL_END
