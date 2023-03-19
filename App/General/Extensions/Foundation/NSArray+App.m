
#import "NSArray+App.h"

@implementation NSArray (App)

- (nonnull NSArray *)historyArrayWithNewItems:(nullable NSArray *)items limit:(NSUInteger)limit {
    NSMutableArray *history = [NSMutableArray arrayWithCapacity:limit];
    NSInteger count = 0;

    for (id item in items) {
        if (![history containsObject:item]) {
            [history addObject:item];
            count++;
        }
        if (count >= limit) {
            return history;
        }
    }

    for (id item in self) {
        if (![history containsObject:item]) {
            [history addObject:item];
            count++;
        }
        if (count >= limit) {
            return history;
        }
    }

    return history;
}

@end


@implementation NSMutableArray (App)

- (void)rf_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index >= self.count || !anObject) return;
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    id object = self[fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end


