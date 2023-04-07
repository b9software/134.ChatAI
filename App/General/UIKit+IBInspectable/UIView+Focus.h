/*
 UIView+Focus
 
 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+IBInspectable.h"

/**
 Interface Builder 中没提供这两项的开关
 */
@interface UIView (IBInspectable)
@property (nonatomic) IBInspectable NSString *focusGroupIdentifier;
@end
