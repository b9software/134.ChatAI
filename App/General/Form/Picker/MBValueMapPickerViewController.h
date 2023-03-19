/*
 MBValueMapPickerViewController
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBModalPresentSegue.h"

// @MBDependency:2
/**
 给一组数据，从中选择一个
 
 备忘：
 使用实例的 - presentFromViewController:animated:completion: 方法弹出
 
 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
@interface MBValueMapPickerViewController<ObjectType> : MBModalPresentViewController

@property (weak, nullable, nonatomic) IBOutlet UIPickerView *pickerView;

/**
 values 为空时会显示出来，但控件默认不生成这个 label
 */
@property (weak, nullable, nonatomic) IBOutlet UILabel *emptyLabel;

/**
 选择器中的对象，可以 picker 显示出来后异步设置
 */
@property (nullable, nonatomic) NSArray<ObjectType> *values;

/**
 选择器刷新时默认滚动到该对象对应的列
 */
@property (nullable, nonatomic) ObjectType selectedVaule;

/**
 修改该属性决定如何展示 value，优先级最高
 */
@property (nullable) NSString *__nullable (^valueDisplayString)(ObjectType __nullable value);

/**
 修改该属性决定如何展示 value
 
 如果未设置或者 value 不在 map 中，继续下面的尝试：
 1. 如果 value 实现了 MBItemExchanging 中的 displayString，则显示该方法的返回值
 2. 使用 value 的 description
 */
@property (nullable) NSDictionary<ObjectType, NSString *> *valueDisplayMap;

/**
 选择结果的回调，调用后置空
 
 如果取消 selectedVaule 为空
 */
@property (nullable) void (^didEndSelection)(MBValueMapPickerViewController *__nonnull picker, ObjectType  __nullable selectedVaule);

@end
