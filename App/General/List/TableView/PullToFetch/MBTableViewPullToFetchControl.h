/*
 MBTableViewPullToFetchControl
 
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "RFTableViewPullToFetchPlugin.h"
#import "MBRefreshHeaderView.h"
#import "MBRefreshFooterView.h"

// @MBDependency:4
/**
 RFTableViewPullToFetchPlugin 只是处理了下拉、上推的逻辑，没有包含外观。
 
 这个类对外观进行了进一步的封装，外观的调整需修改 MBRefreshHeaderView 和 MBRefreshFooterView。
 */
@interface MBTableViewPullToFetchControl : RFTableViewPullToFetchPlugin
@property MBRefreshHeaderView *headerContainer;
@property MBRefreshFooterView *footerContainer;
@end
