/*
 MBCollectionViewFlowLayout
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:3
/**
 UICollectionViewFlowLayout 等价体，修正特定版本系统的 bug

 当前已无任何修正
 */
@interface MBCollectionViewFlowLayout : UICollectionViewFlowLayout <
    RFInitializing
>

@end
