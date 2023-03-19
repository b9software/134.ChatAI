/*!
 MBNotificationIndicator
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFKit.h>

/**
 自动监听状态的小红点，图片显示

 监听 AppBadge() 单例的键值，
 MBNotificatioBadgeChangedNotification 通知时更新
 
 ## 使用
 
 - 项目需要定义 MBNotificatioBadgeChangedNotification 通知常量和 AppBadge()（类型不限）
 - AppBadge() 上数量变化时发送 MBNotificatioBadgeChangedNotification 通知
 
 */
@interface MBNotificationIndicator : UIImageView <
    RFInitializing
>
/**
 监听 AppBadge() 的键值，通过 valueForKeyPath: 读取，之后通过 boolValue 方法转为 BOOL
 
 指定的键值通常是 BOOL 量或数字
 */
@property (nullable) IBInspectable NSString *observerProperty;

/**
 根据当前读取到的状态，返回是否应该显示
 */
@property (readonly) BOOL shouldShow;

/**
 处于禁用状态当新通知来的时候不刷新状态
 */
@property IBInspectable BOOL disabled;

/**
 更新状态，会自动调用，外部需要强制刷新时可以手动调用
 */
- (void)updateStatus;

@end

/**
 自动监听状态的小红点，数字显示

 监听 AppBadge() 单例的键值，
 MBNotificatioBadgeChangedNotification 通知时更新
 */
@interface MBNotificationNumberIndicator : UILabel <
    RFInitializing
>
/**
 监听 AppBadge() 的键值，通过 valueForKeyPath: 读取，之后通过 longValue 方法转为整型
 */
@property (nullable) IBInspectable NSString *observerProperty;

/**
 当前读取到的数量
 */
@property (readonly) long count;

/**
 最大显示数字，超出后显示为 max+
 */
@property IBInspectable long maxCount;

/**
 处于禁用状态当新通知来的时候不刷新状态
 */
@property (nonatomic) IBInspectable BOOL disabled;

/**
 更新状态，会自动调用，外部需要强制刷新时可以手动调用
 */
- (void)updateStatus;

#if TARGET_INTERFACE_BUILDER
@property IBInspectable CGRect contentInset;
#else
@property UIEdgeInsets contentInset;
#endif

/**
 设置为 YES，当数量变化时调用 sizeToFit 更新尺寸和位置，保持 center 不变
 
 默认 NO
 */
@property IBInspectable BOOL autoFitSize;

/**
 如果设置，会把自身加入到 button 的子 view 中，并设置约束以便自动更新布局
 */
@property (weak, nullable, nonatomic) IBOutlet UIButton *layoutBindButton;

@end
