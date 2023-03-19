
#import "MBCollectionViewArrayDataSource.h"
#import "NSArray+App.h"
#import <RFKit/NSArray+RFKit.h>

@interface MBCollectionViewArrayDataSource ()
@end

@implementation MBCollectionViewArrayDataSource
RFInitializingRootForNSObject

- (void)onInit {

}

- (void)afterInit {
    // Nothing
}

- (nullable id)itemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    BOOL hasFirstItem = self.hasFirstItem;
    if ([self isFirstItemIndexPath:indexPath]) {
        return self.firstItemObject;
    }
    _dout_int(indexPath.item - !!hasFirstItem)
    return [self.items rf_objectAtIndex:indexPath.item - !!hasFirstItem];
}

- (NSArray *)itemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!indexPaths.count) return nil;
    BOOL hasFirstItem = self.hasFirstItem;

    return [indexPaths rf_mapedArrayWithBlock:^id _Nullable(NSIndexPath *ip) {
        if (hasFirstItem && ip.item == 0) {
            return self.firstItemObject;
        }
        return [self.items rf_objectAtIndex:ip.item - !!hasFirstItem];
    }];
}

- (nullable NSIndexPath *)indexPathForItem:(nonnull id)item {
    if (!item) return nil;
    BOOL hasFirstItem = self.hasFirstItem;
    if (self.items) {
        NSInteger idx = [self.items indexOfObject:item];
        if (idx != NSNotFound) {
            return [NSIndexPath indexPathForRow:idx + !!hasFirstItem inSection:0];
        }
    }
    if (item == self.firstItemObject) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return nil;
}

- (void)setItems:(NSArray *)items {
    BOOL keep = self.keepSelectionAfterReload;
    NSArray<id> *selectedItems = keep ? self.selectedItems : nil;
    _items = items.copy;
    [self.collectionView reloadData];
    if (keep) {
        self.selectedItems = selectedItems;
    }
}

- (NSArray<id> *)selectedItems {
    return [self itemsAtIndexPaths:self.collectionView.indexPathsForSelectedItems];
}

- (void)setSelectedItems:(NSArray *)selectedItems {
    [self.collectionView performBatchUpdates:^{
        NSArray<NSIndexPath *> *oldIPs = self.collectionView.indexPathsForSelectedItems;
        NSArray<NSIndexPath *> *newIPs = [selectedItems rf_mapedArrayWithBlock:^id _Nullable(id obj) {
            return [self indexPathForItem:obj];
        }];
        NSArray<NSIndexPath *> *removeIPs = [oldIPs rf_mapedArrayWithBlock:^id _Nullable(NSIndexPath *ip) {
            return [newIPs containsObject:ip] ? nil : ip;
        }];
        for (NSIndexPath *ip in removeIPs) {
            [self.collectionView deselectItemAtIndexPath:ip animated:YES];
        }
        for (NSIndexPath *ip in newIPs) {
            [self.collectionView selectItemAtIndexPath:ip animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    } completion:nil];
}

- (nonnull NSString *)cellIdentifierAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self isFirstItemIndexPath:indexPath]) {
        return self.firstItemReuseIdentifier;
    }
    if (self.cellIdentifierProvider) {
        return self.cellIdentifierProvider(self, [self itemAtIndexPath:indexPath], indexPath);
    }
    return @"Cell";
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count + !!self.hasFirstItem;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<MBSenderEntityExchanging> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setItem:)]) {
        cell.item = [self itemAtIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isFirstItemIndexPath:indexPath]) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self isFirstItemIndexPath:sourceIndexPath]
        || [self isFirstItemIndexPath:destinationIndexPath]) {
        return;
    }
    BOOL hasFirstItem = self.hasFirstItem;
    NSMutableArray *items = self.items.mutableCopy;
    [items moveObjectAtIndex:sourceIndexPath.item - !!hasFirstItem toIndex:destinationIndexPath.item - !!hasFirstItem];
    _items = items;
}

#pragma mark - Additional Item

- (NSInteger)_arrayIndexForIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return NSNotFound;
    return indexPath.item - !!self.hasFirstItem;
}

- (NSIndexPath *)_indexPathForArrayIndex:(NSInteger)idx {
    return [NSIndexPath indexPathForRow:idx + !!self.hasFirstItem inSection:0];
}

- (BOOL)hasFirstItem {
    return self.firstItemReuseIdentifier != nil;
}

- (BOOL)isFirstItemIndexPath:(NSIndexPath *)indexPath {
    if (!self.hasFirstItem) return NO;
    return (indexPath.item == 0);
}

#pragma mark - List operation

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isFirstItemIndexPath:indexPath]) {
        self.firstItemReuseIdentifier = nil;
        self.firstItemObject = nil;
        [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
        return;
    }
    NSInteger idx = [self _arrayIndexForIndexPath:indexPath];
    NSParameterAssert(idx != NSNotFound);
    NSMutableArray *items = self.items.mutableCopy;
    [items removeObjectAtIndex:idx];
    _items = items;
    [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
}

- (NSIndexPath *)appendItem:(id)item {
    if (!item) return nil;
    NSMutableArray *items = [NSMutableArray.alloc initWithArray:self.items];
    [items addObject:item];
    _items = items;
    NSIndexPath *ip = [self _indexPathForArrayIndex:items.count - 1];
    [self.collectionView insertItemsAtIndexPaths:@[ ip ]];
    return ip;
}

@end
