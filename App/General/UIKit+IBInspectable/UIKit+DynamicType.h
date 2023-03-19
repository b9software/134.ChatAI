/*
 UIKit+DynamicType

 Copyright © 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+IBInspectable.h"

/**
 Interface Builder 目前只有设置成 text styles 的样式才能自动调节大小，
 设置自定义字体无 dynamic type 效果。

 这里的扩展便于使用自定义字体时也能低成本支持 dynamic type。
 */

@interface UILabel (IBDynamicType)
@property IBInspectable BOOL dynamicTypeEnabled;
@end

@interface UIButton (IBDynamicType)
@property IBInspectable BOOL dynamicTypeEnabled;
@end
