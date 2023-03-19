/*!
 PushManager
 
 Copyright © 2018 RFUI. All rights reserved.
 https://github.com/RFUI/MBAppKit
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

/**
 推送管理器，个推实现

 使用：
 1. managerWithConfiguration: 初始化实例，注意外部必须保存返回实例的引用，否则会自行释放掉
 2. 创建后会自行注册到 MBApplicationDelegate 上，不需要在其他文件中写任何代码
 3. 设置 receiveRemoteNotificationHandler, receiveLocalNotificationHandler 响应通知
 
 这个类是按原样使用设计的，既不应该重写，也不应该拿来修改。
 
 ## 关于个推
 
 - 推荐导入方式 pod 'GTSDK', '2.3.0.0-noidfa'
 - 个推管理端 https://dev.getui.com
 - 更新日志 http://docs.getui.com/getui/version/
 
 */
@interface PushManager : NSObject <
    UIApplicationDelegate,
    RFInitializing
>

#pragma mark - 初始状态配置

/**
 如果配置不符合要求会抛出 NSInternalInconsistencyException 异常

 @param configBlock 不能为空，在这个 block 里进行设置
 */
+ (nonnull instancetype)managerWithConfiguration:(NS_NOESCAPE void (^_Nonnull)(PushManager *_Nonnull manager))configBlock;

/// 个推的信息
@property (nonnull) NSString *appID;
@property (nonnull) NSString *appKey;
@property (nonnull) NSString *appSecret;

/// 应用启动时的 launchOptions
/// manager 创建后会被清空
@property (nonatomic, nullable) NSDictionary *launchOptions;

#pragma mark -

/// 处理收到的通知
/// notification 可能是 UNNotification
@property (nullable) void (^receiveRemoteNotificationHandler)(NSDictionary *__nonnull info, id __nullable notification, BOOL userClick);

/// 处理收到的本地通知
/// notification 可能是 UILocalNotification 或 UNNotification
@property (nullable) void (^receiveLocalNotificationHandler)(NSDictionary *__nonnull info, id __nullable notification, BOOL userClick);

/**
 最后收到的推送，可以用于判断通知收到的时机
 
 如果最近一条是本地通知，内容是通知对象的 userInfo
 */
@property (nullable) NSDictionary *lastNotificationReceived;

/**
 暴露个推的 clientID
 */
@property (class, nullable, readonly) NSString *pushID;

@property (nonatomic, nullable, copy) NSString *deviceToken;
+ (nonnull NSString *)stringFromDeviceToken:(nonnull NSData *)deviceToken;

#pragma mark - Alias Tag

/// 设置时执行更新
@property (nonatomic, nullable, copy) NSString *pushAlias;

/**
 设置推送 tags
 
 如果设置失败，属性值不会更新
 */
@property (nonatomic, nonnull) NSSet *pushTags;

#pragma mark - 角标管理

/**
 应用启动后重置角标，需要实例创建后立即设置
 
 默认 YES
 */
@property BOOL resetBadgeAfterLaunching;

/**
 应用进入前台后重置角标
 
 默认 NO
 */
@property (nonatomic) BOOL resetBadgeWhenApplicationBecomeActive;

/**
 清空本地应用和个推服务器上的 badge
 */
- (void)resetBadge;

@end
