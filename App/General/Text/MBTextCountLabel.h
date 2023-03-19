/*
 MBTextCountLabel
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 显示关联 textView 的文字长度，若超出指定长度，label 将变为高亮状态

 默认的显示是：
 - 若 textView 未设置，文字置空；
 - 若 maxLength 未设置/为 0，只显示当前字数，不显示超出状态；
 - 正常显示「当前字数/最大字数」，超出 maxLength 置为高亮状态。
 */
@interface MBTextCountLabel : UILabel <
    RFInitializing
>

/**
 关联的 text view，文本修改时 count label 显示随之更新
 */
@property (weak, nullable, nonatomic) IBOutlet UITextView *textView;

/**
 最大字符长度，超出 count label 外观改变以达到提示目的

 不会限制 textView 实际输入
 */
@property (nonatomic) IBInspectable NSUInteger maxLength;

/**
 定制最大字数部分的颜色，默认空
 */
@property (nullable) IBInspectable UIColor *maxLengthColor;

/**
 如果用代码设置 textView 的文本，label 状态不会更新，可用该方法强制更新
 */
- (void)updateUIForTextChanged;

/**
 自定义 textView 文本变化时如何更新 count label 样式
 */
@property (nullable) void (^textChangeUpdateBlock)(__kindof MBTextCountLabel *__nonnull label);

@end
