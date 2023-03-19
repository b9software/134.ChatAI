
#import "MBScrollViewOffsetObserver.h"
#import <RFAlpha/RFKVOWrapper.h>

@interface MBScrollViewContentOffsetControl ()
@property (strong, nonatomic) id contentOffsetObserver;
@property (readwrite, nonatomic) CGPoint lastOffset;
@property (readwrite, nonatomic) CGPoint continuousOffset;

@property (strong, nonatomic) NSMutableArray *observers;
@end

@implementation MBScrollViewContentOffsetControl
RFInitializingRootForNSObject

- (void)onInit {
    self.observers = [NSMutableArray new];
}

- (void)afterInit {
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        if (_scrollView) {
            [_scrollView RFRemoveObserverWithIdentifier:self.contentOffsetObserver];
        }

        _scrollView = scrollView;
        [self reset];

        if (scrollView) {
            self.contentOffsetObserver = [scrollView RFAddObserver:self forKeyPath:@keypath(scrollView, contentOffset) options:NSKeyValueObservingOptionNew queue:nil block:^(MBScrollViewContentOffsetControl *observer, NSDictionary *change) {
                [observer _contentOffsetChanged];
            }];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        [self _contentOffsetChanged];
    }
}

- (void)_contentOffsetChanged {
    if (!self.scrollView) return;
    if (!self.enabled) return;

    CGPoint const offset = self.scrollView.contentOffset;
    CGPoint const lastOffset = self.lastOffset;
    if (CGPointEqualToPoint(lastOffset, offset)) return;
    CGPoint continuousOffset = self.continuousOffset;

    CGPoint diffOffset = (CGPoint){ offset.x - lastOffset.x, offset.y - lastOffset.y };
    if (diffOffset.x * continuousOffset.x < 0) {
        continuousOffset.x = diffOffset.x;
    }
    else {
        continuousOffset.x += diffOffset.x;
    }
    if (diffOffset.y * continuousOffset.y < 0) {
        continuousOffset.y = diffOffset.y;
    }
    else {
        continuousOffset.y += diffOffset.y;
    }

    _dout_point(continuousOffset)
    _dout_point(offset)
    self.continuousOffset = continuousOffset;
    self.lastOffset = offset;

    for (MBScrollViewContentOffsetObserver *observer in self.observers) {
        if (!observer.enabled) continue;
        if (!observer.testBlock(self, offset)) continue;
        @weakify(self);
        dispatch_async_on_main(^{
            @strongify(self);
            if (!self) return;
            if (!CGPointEqualToPoint(self.scrollView.contentOffset, offset)) return;
            observer.execution(self, offset);
        });
    }
}

- (void)reset {
    self.lastOffset = CGPointZero;
    self.continuousOffset = CGPointZero;
}

#pragma mark - Observer

- (nonnull MBScrollViewContentOffsetObserver *)addObserverPassingTest:(nonnull BOOL (^)(MBScrollViewContentOffsetControl * __nonnull, CGPoint))testBlock execution:(nonnull void (^)(MBScrollViewContentOffsetControl * __nonnull, CGPoint))executionBlock {
    NSParameterAssert(testBlock);
    NSParameterAssert(executionBlock);

    MBScrollViewContentOffsetObserver *ob = [MBScrollViewContentOffsetObserver new];
    ob.enabled = YES;
    ob.testBlock = testBlock;
    ob.execution = executionBlock;
    [self.observers addObject:ob];

    return ob;
}

- (void)removeObserver:(nullable MBScrollViewContentOffsetObserver *)observer {
    [self.observers removeObject:observer];
}

@end


@implementation MBScrollViewContentOffsetObserver


@end
