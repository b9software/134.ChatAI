/*
 MBPageScrollView
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:1
/**
 分页支持的 ScrollView
 
 */
@interface MBPageScrollView : UIScrollView <
    RFInitializing
>

@property(nonatomic) NSInteger page;
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

@property (readonly, nonatomic) NSInteger totalPage;

@end


@interface UIScrollView (MBPageScrolling)

- (NSInteger)MBPage;

- (void)MBSetPage:(NSInteger)page animated:(BOOL)animated;

@end
