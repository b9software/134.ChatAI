/*
 MBFormSelectButton
 
 Copyright © 2018-2020 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBButton.h"

// @MBDependency:1

/**
 有选中值的按钮，按钮文本根据选中值变化

 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
@interface MBFormSelectButton<ObjectType> : MBButton

@property (nullable, nonatomic) ObjectType selectedVaule;

/// 占位符文本，默认使用 nib 中定义的 normal 文本
@property (nullable, nonatomic) IBInspectable NSString *placeHolder;

/// 修改该属性决定如何展示数值，优先于 valueDisplayMap
/// 未设置则显示 value 的 description
@property (nullable, nonatomic) NSString *__nullable (^valueDisplayString)(ObjectType __nullable value);

/// 修改该属性决定如何展示数值
/// 未设置则显示 value 的 description
@property (nullable) NSDictionary<ObjectType, NSString *> *valueDisplayMap;

/// 决定 value 如何显示，供子类重写
- (nullable NSString *)displayStringWithValue:(nullable ObjectType)value;

@end
