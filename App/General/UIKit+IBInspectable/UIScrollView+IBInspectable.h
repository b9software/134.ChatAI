/*
 UIScrollView+IBInspectable
 
 Copyright © 2018, 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+IBInspectable.h"

/**
 Interface Builder 中没提供这项的开关
 */
@interface UIScrollView (IBInspectable)
@property (nonatomic) IBInspectable BOOL scrollsToTop;
@end
