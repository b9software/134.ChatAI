/*!
 MBCollectionRefreshFooterView
 
 Copyright © 2018, 2020 BB9z.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFAlpha/RFRefreshControl.h>

// @MBDependency:1
/**
 Collection view 的上拉加载下一页
 */
@interface MBCollectionRefreshFooterView : UICollectionReusableView

@property (nonatomic) RFRefreshControlStatus status;

/**
 
 默认点击会通过 Responder chain 执行 onLoadNextPage:
 */
@property (weak, nonatomic) IBOutlet UIButton *loadButton;

#pragma mark - 到底

@property (readonly, nonatomic) BOOL end;

@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UIView *endView;
@property (strong, nonatomic) UIView *customEndView;

#pragma mark - 内容为空

@property (readonly, nonatomic) BOOL empty;

@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) UIView *customEmptyView;
@property (weak, nonatomic) IBOutlet UIView *outerEmptyView;

@end
