/*
 MBFormSelectListViewController

 Copyright © 2020 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

@class RFTimer;

typedef NS_ENUM(short, MBFormSelectListReturnType) {
    MBFormSelectListReturnTypePop = 0,
    MBFormSelectListReturnTypeDismiss,
    MBFormSelectListReturnTypeNoAction
};

// @MBDependency:1 需要升级
/**
 选择列表控制器
 
 使用：
 
 设置 items 和 selectedItems 属性，选择结果会通过 didEndSelection 的 block 返回，选项的展示由 MBFormSelectTableViewCell 控制

 是否支持多选可在 Storyboard 中设置 allowsMultipleSelection 属性
 
 如果需要异步设置数据源（如从网络获取数据），子类该类后设置 items 即可
 */
@interface MBFormSelectListViewController : UITableViewController <
    RFInitializing
>

#pragma mark - 数据源

/**
 设置该属性决定列表中有哪些选项

 修改该属性会自动刷新列表
 */
@property (strong, nonatomic) NSArray *items;

/**
 筛选后的结果
 
 列表展现的数据是 filteredItems 而不是 items，修改该属性不会自动刷新列表
 默认实现为空，此时会使用 items 中的元素
 */
@property (strong, nonatomic) NSArray *filteredItems;

/**
 该属性用于设置已选项，不会随 tableView 选择而变化
 
 数组中的元素是 items 中已选择的对象
 */
@property (copy, nonatomic) NSArray *selectedItems;

#pragma mark - 列表更新

/// 立即刷新列表
- (void)updateUIForItem;

/// 标记列表需要更新，在 viewWillAppear: 时执行更新
- (void)updateUIForItemIfNeeded;

/// sender 并未使用，也适用于一般情形下的标记
- (IBAction)setNeedsUpdateUIWithSegue:(UIStoryboardSegue *)sender;

#pragma mark - 选择回调

/// 选择结果的回调
/// 完成选择时执行
@property (copy, nonatomic) void (^didEndSelection)(id listController, NSArray *selectedItems);

#pragma mark - 返回控制

/**
 选中任一选项自动返回
 
 默认 NO
 */
@property (nonatomic) IBInspectable BOOL returnWhenSelected;

/// 需要手动按保存才能改变选择结果
/// 默认 NO，当 viewWillDisappear 时自动返回新的选择结果
@property (nonatomic) IBInspectable BOOL requireUserPressSave;

/// 当用户需要手动保存时，需要把该方法连接到保存按钮上
- (IBAction)onSaveButtonTapped:(id)sender;

/// 返回执行操作，pop，dismiss 还是无动作
@property (nonatomic) MBFormSelectListReturnType returnType;

#pragma mark -

/// 清空已选
- (IBAction)onClearSelection:(id)sender;

/// 清空已选并返回
- (IBAction)onClearSelectionAndReturn:(id)sender;

#pragma mark - 搜索支持
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/// 搜索中的关键字
@property (copy, nonatomic) NSString *searchingKeyword;

/// 搜索操作
/// 设置新的会自动取消旧的操作
@property (weak, nonatomic) NSOperation *searchOperation;

/**
 默认实现当搜索框文字修改后延迟一段时间后自动执行搜索操作
 */
@property (strong, nonatomic) RFTimer *autoSearchTimer;

/// 默认 0.6 s
/// 设置为 0 关闭搜索
@property (nonatomic) IBInspectable float autoSearchTimeInterval;

/**
 子类需重写返回搜索结果
 
 例：
 
 @code
- (void)doSearchWithKeyword:(NSString *)keyword {
    [super doSearchWithKeyword:keyword];

    [API requestWithName:@"Search" parameters:@{ @"keyword" : keyword?: @"" } viewController:self loadingMessage:@"" modal:NO success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        self.filteredItems = responseObject;
        [self updateUIForItem];
    } completion:nil];
}
 @endcode
 
 @param keyword 搜索关键字，可能为 nil
 */
- (void)doSearchWithKeyword:(NSString *)keyword;

// 这个类实现了 UISearchBarDelegate 中的两个方法
#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end


@protocol MBFormSelectTableViewCell <NSObject>
@property (strong, nonatomic) id value;
@end


@interface MBFormSelectTableViewCell : UITableViewCell <
    MBFormSelectTableViewCell
>
@property (strong, nonatomic) id value;
@property (weak, nonatomic) IBOutlet UILabel *valueDisplayLabel;

/**
 子类重写这个方法决定如何展示数值
 
 默认实现若 value 支持 MBItemExchanging 的 displayString，则显示 displayString，否则显示 value 的 description
 */
- (void)displayForValue:(id)value;

@end
