/*
 MBCollectionViewArrayDataSource
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <MBAppKit/MBAppKit.h>

// @MBDependency:4
/**
 数组作为数据源的 data source
 
 提供：
 - 可选在正常数据前添加一个特殊 cell
 */
@interface MBCollectionViewArrayDataSource<__covariant ObjectType> : NSObject <
    RFInitializing,
    UICollectionViewDataSource
>
/// 可选择设置，如果设置了数据源更新后会自动刷新 collection view
@property (weak, nullable, nonatomic) IBOutlet UICollectionView *collectionView;

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

@property (nullable) NSString *_Nonnull (^cellIdentifierProvider)(__kindof MBCollectionViewArrayDataSource *_Nonnull dataSource, ObjectType _Nonnull item, NSIndexPath *_Nonnull indexPath);

#pragma mark - Additional Item

/// 第一个特殊 cell 的标识
/// 设置则添加
@property (copy, nullable) IBInspectable NSString *firstItemReuseIdentifier;

/// 可选，绑定在第一个特殊 cell 的对象
@property (nullable) id firstItemObject;

- (BOOL)isFirstItemIndexPath:(nonnull NSIndexPath *)indexPath;

/// 最后一个特殊 cell 的标识
/// 设置则添加
@property (copy, nullable) IBInspectable NSString *lastItemReuseIdentifier __attribute__((unavailable("暂未实现")));

/// 列表项最多元素个数，0 不限制
@property IBInspectable NSUInteger maxItemsCount __attribute__((unavailable("暂未实现")));

#pragma mark - List operation

/**
 删除指定单元
 
 如果 indexPath 指的是第一个特殊 cell，会清空 firstItemReuseIdentifier 和 firstItemObject 属性
 */
- (void)deleteItemAtIndexPath:(nullable NSIndexPath *)indexPath;

/**
 附加一个对象在末尾
 
 @return 插入对象对应的 index path
 */
- (nullable NSIndexPath *)appendItem:(nullable ObjectType)item;

@end
