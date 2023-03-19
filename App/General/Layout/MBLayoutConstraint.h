/*
 MBLayoutConstraint
 
 Copyright © 2018 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <UIKit/UIKit.h>

// @MBDependency:2
/**
 增加了折叠展开支持
 */
@interface MBLayoutConstraint : NSLayoutConstraint

@property (nonatomic) IBInspectable BOOL expand;
- (void)setExpand:(BOOL)expand animated:(BOOL)animated;

/**
 折叠起来的约束量
 */
@property (nonatomic) IBInspectable CGFloat contractedConstant;

/**
 展开的约束量

 如未设置（为0），将在 awakeFromNib 时设置为当前约束量
 */
@property (nonatomic) IBInspectable CGFloat expandedConstant;
@end
