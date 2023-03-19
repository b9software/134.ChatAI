/*
 MBFlipCollapsibleView
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <UIKit/UIKit.h>
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFGeometry.h>

// @MBDependency:1
/**
 利用 layer mask 展开收起的 view
 收起后需要外部手动设置隐藏
 */
@interface MBFlipCollapsibleView : UIView <
    RFInitializing
>

/// 收起的朝向
/// 目前只支持 top、bottom；默认 top
@property (nonatomic) RFResizeAnchor direction;

/// 默认 YES
@property (nonatomic) IBInspectable BOOL expand;
@end
