/*
 UICollectionViewFlowLayout+IBSelection
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+IBInspectable.h"

/**
 Interface Builder 中没提供这项的开关
 */
@interface UICollectionViewFlowLayout (IBInspectable)
@property (nonatomic) IBInspectable CGSize estimatedItemSize;
@end
