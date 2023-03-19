/*
 MBTableHeaderFooterView
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:3
/**
 可以用 AutoLayout 自动调节高度的 tableHeaderView/tableFooterView
 
 使用：
    
    一般在 IB 中加一个 contentView 作为容器，然后用 AutoLayout 撑开 contentView

 */
@interface MBTableHeaderFooterView : UIView <
    RFInitializing,
    RFOnlySupportLoadFromNib
>

/// 子 view 的容器，MBTableHeaderFooterView 的高度会跟它的高度同步
/// 如果不设置，高度不会自行改变
@property (weak, nonatomic) IBOutlet UIView *contentView;

/// 刷新高度的方法，正常会自动更新，一般不用调用
- (void)updateHeight;
- (void)updateHeightAnimated:(BOOL)animated;

/// 代码方式安装为 tableHeaderView
- (void)setupAsHeaderViewToTableView:(UITableView *)tableView;

/// 代码方式安装为 tableFooterView
- (void)setupAsFooterViewToTableView:(UITableView *)tableView;
@end
