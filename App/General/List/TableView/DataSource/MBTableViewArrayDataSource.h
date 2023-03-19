/*
 MBTableViewArrayDataSource
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <MBAppKit/MBAppKit.h>

// @MBDependency:3
/**
 数组作为数据源的 data source
 */
@interface MBTableViewArrayDataSource<__covariant ObjectType> : NSObject <
    RFInitializing,
    UITableViewDataSource
>
/// 可选择设置，如果设置了数据源更新后会自动刷新 table view
@property (weak, nullable, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nullable, nonatomic) NSArray<ObjectType> *items;

/// 不支持 KVO
@property (nullable, nonatomic) NSArray<ObjectType> *selectedItems;

/**
 重载后保持之前的对象选中，即使顺序、元素个数已改变
 
 当前只支持设置 items 属性后保持不变
 */
@property IBInspectable BOOL keepSelectionAfterReload;

/**
 @param indexPath 为空会抛出异常
 */
- (nullable ObjectType)itemAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nullable NSArray<ObjectType> *)itemsAtIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;

- (nullable NSIndexPath *)indexPathForItem:(nonnull ObjectType)item;

@property (nullable) NSString *__nonnull (^cellIdentifierProvider)(__kindof MBTableViewArrayDataSource *__nonnull dataSource, ObjectType __nonnull item, NSIndexPath *__nonnull indexPath);

#pragma mark - List operation
// 这些操作会更新单元对应的数据

/**
 删除指定单元
 
 @param indexPath 为空什么也不做。如果越界在 DEBUG 模式下断言异常
 */
- (void)deleteRowAtIndexPath:(nullable NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 移动 cell 到另一个位置
 
 @param indexPath 如果不合法会忽略
 @param newIndexPath 如果越界会崩溃
 */
- (void)moveRowAtIndexPath:(nullable NSIndexPath *)indexPath toIndexPath:(nullable NSIndexPath *)newIndexPath;

@end
