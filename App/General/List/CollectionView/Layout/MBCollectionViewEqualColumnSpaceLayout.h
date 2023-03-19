/*
 MBCollectionViewEqualColumnSpaceLayout
 
 Copyright © 2018-2019 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBCollectionViewFlowLayout.h"

typedef NS_ENUM(NSInteger, MBCollectionViewColumnLayoutStyle) {
    /// sectionInset 的左右和 minimumInteritemSpacing 相同
    MBCollectionViewColumnLayoutStyleSectionInsetEqualItemSpacing = 0,
    /// 整个宽度按列数等分，cell 位于每块区域的中心
    MBCollectionViewColumnLayoutStyleCenter,
    /// 左右无边距的均分
    MBCollectionViewColumnLayoutStyleNoSectionInset,
};

// @MBDependency:2
/**
 把 collectionView 分成给定列数并对齐
 */
@interface MBCollectionViewEqualColumnSpaceLayout : MBCollectionViewFlowLayout

/// 列数
@property (nonatomic) IBInspectable NSUInteger numberOfColumns;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSInteger layoutStyle;
#else
@property (nonatomic) MBCollectionViewColumnLayoutStyle layoutStyle;
#endif

@end
