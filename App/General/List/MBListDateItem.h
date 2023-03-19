/*
 MBListDateItem
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBModel.h"

NS_ASSUME_NONNULL_BEGIN

// @MBDependency:2
@interface MBListDataItem<ObjectType> : NSObject <
    MBModel
>

@property (nonatomic, nullable) ObjectType item;
@property (nonatomic) NSString *cellReuseIdentifier;

+ (instancetype)dataItemWithItem:(nullable ObjectType)item cellReuseIdentifier:(NSString *)identifier;

@end

// @MBDependency:2
@interface MBListSectionDataItem<SectionType, RowType> : NSObject

@property (nonatomic, nullable) SectionType sectionItem;
@property (nonatomic) NSString *sectionIndicator;
@property (nonatomic) NSMutableArray<MBListDataItem<RowType> *> *rows;

+ (instancetype)dataItemWithSectionItem:(nullable SectionType)sectionItem sectionIndicator:(NSString *)sectionIndicator rows:(NSMutableArray<MBListDataItem<RowType> *> *)rows;

@end

void MBListDataItemAddToItems(NSString *cellIdentifier, id __nullable item, NSMutableArray *items);

NS_ASSUME_NONNULL_END
