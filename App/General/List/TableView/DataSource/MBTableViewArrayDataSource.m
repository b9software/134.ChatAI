
#import "MBTableViewArrayDataSource.h"

@interface MBTableViewArrayDataSource ()

@end

@implementation MBTableViewArrayDataSource
RFInitializingRootForNSObject

- (void)onInit {

}

- (void)afterInit {
    // Nothing
}

- (nullable id)itemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    return self.items[indexPath.row];
}

- (NSArray *)itemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!indexPaths.count) return nil;
    
    return [indexPaths rf_mapedArrayWithBlock:^id _Nullable(NSIndexPath *ip) {
        return [self.items rf_objectAtIndex:ip.row];
    }];
}

- (nullable NSIndexPath *)indexPathForItem:(nonnull id)item {
    NSInteger idx = [self.items indexOfObject:item];
    if (idx != NSNotFound) {
        return [NSIndexPath indexPathForRow:idx inSection:0];
    }
    return nil;
}

- (void)setItems:(NSArray *)items {
    BOOL keep = self.keepSelectionAfterReload;
    NSArray *selectedItems = keep ? self.selectedItems : nil;
    _items = items.copy;
    [self.tableView reloadData];
    if (keep) {
        self.selectedItems = selectedItems;
    }
}

- (NSArray *)selectedItems {
    return [self itemsAtIndexPaths:self.tableView.indexPathsForSelectedRows];
}

- (void)setSelectedItems:(NSArray *)selectedItems {
    NSArray<NSIndexPath *> *oldIPs = self.tableView.indexPathsForSelectedRows;
    NSArray<NSIndexPath *> *newIPs = [selectedItems rf_mapedArrayWithBlock:^id _Nullable(id obj) {
        return [self indexPathForItem:obj];
    }];
    NSArray<NSIndexPath *> *removeIPs = [oldIPs rf_mapedArrayWithBlock:^id _Nullable(NSIndexPath *ip) {
        return [newIPs containsObject:ip] ? nil : ip;
    }];
    for (NSIndexPath *ip in removeIPs) {
        [self.tableView deselectRowAtIndexPath:ip animated:YES];
    }
    for (NSIndexPath *ip in newIPs) {
        [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (nonnull NSString *)cellIdentifierAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.cellIdentifierProvider) {
        return self.cellIdentifierProvider(self, [self itemAtIndexPath:indexPath], indexPath);
    }
    return @"Cell";
}

#pragma mark - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<MBSenderEntityExchanging> *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.item = [self itemAtIndexPath:indexPath];
    return cell;
}

#pragma mark - List operation

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;

    NSInteger row = indexPath.row;
    if (row == NSNotFound || row >= self.items.count || row < 0) {
        RFAssert(false, @"indexPath 越界");
        return;
    }
    NSMutableArray *items = self.items.mutableCopy;
    [items removeObjectAtIndex:row];
    _items = items;
    
    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    if (!indexPath || !newIndexPath) return;

    id item = [self.items rf_objectAtIndex:indexPath.row];
    if (!item) return;

    NSMutableArray *items = self.items.mutableCopy;
    [items removeObjectAtIndex:indexPath.row];
    [items insertObject:item atIndex:newIndexPath.row];
    _items = items;

    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

@end
