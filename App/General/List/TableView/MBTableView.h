/*
 MBTableView
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>
#import "MBTableViewPullToFetchControl.h"
#import "MBTableViewDataSource.h"

// @MBDependency:4
/**
 Table view 基类

 封装了分页的数据获取（包括下拉刷新、上拉加载更多，数据到底处理）

 修改 keyboardDismissMode，默认拖拽时隐藏键盘
 */
@interface MBTableView : UITableView <
    RFInitializing
>
@property (null_resettable, nonatomic) MBTableViewPullToFetchControl *pullToFetchController;

/**
 便捷设置底部刷新 view 的 outerEmptyView，仅支持 interface builder 中设置
 */
@property (weak, nullable) IBOutlet UIView *outerEmptyView;

/**
 类里已内置了一个强引用的 MBTableViewDataSource
 */
@property (weak, null_resettable, nonatomic) MBTableViewDataSource *dataSource;

/**
 获取数据
 
 pullToFetchController 触发获取操作时调用的就是这个方法，如果要静默更新则可手动调用该方法
 */
- (void)fetchItemsWithPageFlag:(BOOL)nextPage NS_SWIFT_NAME( fetchItems(nextPage:));

/**
 移动到 window 时，如果之前数据没有成功加载，则尝试获取数据，默认关
 */
@property IBInspectable BOOL autoFetchWhenMoveToWindow;

/**
 获取结束后调用
 */
@property (nullable) void (^fetchPageEnd)(BOOL nextPage, MBTableViewDataSource *__nonnull dataSource);

/**
 从列表中删除一个对象的傻瓜方法，会设置好其他该设置的状态
 */
- (void)removeItem:(nullable id)item withRowAnimation:(UITableViewRowAnimation)animation;

/// 重置，以便作为另一个表格展示
- (void)prepareForReuse;

- (void)insertRowsWithRowRange:(NSRange)range inSection:(NSInteger)section rowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsWithRowRange:(NSRange)range inSection:(NSInteger)section rowAnimation:(UITableViewRowAnimation)animation;

@end
