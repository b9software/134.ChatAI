
#import "MBListDateItem.h"

@interface MBListDataItem ()
@end

@implementation MBListDataItem

+ (instancetype)dataItemWithItem:(id)item cellReuseIdentifier:(NSString *)identifier {
    MBListDataItem *this = [self new];
    this.item = item;
    this.cellReuseIdentifier = identifier;
    return this;
}

- (BOOL)ignored {
    return NO;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, item: %@, cellReuseIdentifier: %@>", self.class, self, self.item, self.cellReuseIdentifier];
}

- (NSUInteger)hash {
    if (self.item) {
        return [(NSObject *)self.item hash];
    }
    return [super hash];
}

- (BOOL)isEqual:(MBListDataItem *)other {
    if (other == self) {
        return YES;
    }
    else if (![other isMemberOfClass:[self class]]) {
        return NO;
    }
    else {
        if ([(NSObject *)self.item isEqual:other.item]
            && [self.cellReuseIdentifier isEqualToString:other.cellReuseIdentifier]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation MBListSectionDataItem

+ (instancetype)dataItemWithSectionItem:(nullable id)sectionItem sectionIndicator:(NSString *)sectionIndicator rows:(NSMutableArray<MBListDataItem *> *)rows {
    MBListSectionDataItem *this = [self new];
    this.sectionItem = sectionItem;
    this.sectionIndicator = sectionIndicator;
    this.rows = rows;
    return this;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, section: %@, sectionIndicator: %@,rows: %@>", self.class, self, self.sectionItem, self.sectionIndicator, self.rows];
}

@end

void MBListDataItemAddToItems(NSString *cellIdentifier, id item, NSMutableArray *items) {
    [items addObject:[MBListDataItem dataItemWithItem:item cellReuseIdentifier:cellIdentifier]];
}
