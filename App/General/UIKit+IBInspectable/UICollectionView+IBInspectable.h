/*
 UICollectionView+IBInspectable
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+IBInspectable.h"

/**
 Interface Builder 中没提供这两项的开关
 */
@interface UICollectionView (IBInspectable)
@property (nonatomic) IBInspectable BOOL allowsSelection;
@property (nonatomic) IBInspectable BOOL allowsMultipleSelection;
@end
